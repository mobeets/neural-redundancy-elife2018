function [Z,out] = minEnergyFit(Tr, Te, dec, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'grpName', 'thetaActualGrps', 'makeFAOrthogonal', false, ...
        'noiseDistribution', 'poisson', 'pNorm', 2, 'nReps', 10, ...
        'obeyBounds', true, 'sigmaScale', 1.0, 'addSpikeNoise', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    dispNm = ['minEnergyFit (' opts.minType ')'];
    
    if opts.fitInLatent
        Y1 = Tr.latents;
        Y2 = Te.latents;
    else
        Y1 = Tr.spikes;
        Y2 = Te.spikes;
    end
    
    % set minimum, in latent or spike space
    if strcmpi(opts.minType, 'baseline') && opts.fitInLatent
        mu = [];
    elseif strcmpi(opts.minType, 'baseline') && ~opts.fitInLatent
        mu = dec.spikeCountMean;
    elseif strcmpi(opts.minType, 'minimum') && opts.fitInLatent        
        zers = zeros(size(Tr.spikes,2), 1);
        mu = tools.convertRawSpikesToRawLatents(dec, zers);
    elseif strcmpi(opts.minType, 'minimum') && ~opts.fitInLatent
        mu = [];
    elseif strcmpi(opts.minType, 'best')
        assert(opts.pNorm == 2, 'best-mean assumed to use L2 norm');
        assert(~opts.fitInLatent);
%         mu = findBestMean(Tr.spikes, Tr.NB_spikes, Tr.(opts.grpName));
        mu = hypfit.findBestNeuronMean(Tr.latents, ...
            Te.NB, Te.RB, Tr.(opts.grpName), dec, ...
            0.1*max(Tr.spikes));
        out.bestMean = mu;
        if any(mu < 0)
            warning(['Best mean has negative rates: ' num2str(mu)]);
        end
    else
        assert(false, ['Invalid minType for ' dispNm]);
    end
    sigma = opts.sigmaScale*dec.spikeCountStd;
    
    % set upper and lower bounds
    if opts.obeyBounds
        lb = 1.0*min(Y1); ub = 1.0*max(Y1);
    else
        lb = []; ub = [];
    end
    
    % solve minimization for each timepoint
    [nt, nu] = size(Y2);
    [U, isRelaxed] = hypfit.findAllMinNormFiring(Te, mu, ...
        lb, ub, dec, nu, opts.fitInLatent, ...
        opts.pNorm, opts.makeFAOrthogonal);
    nrs = sum(isRelaxed);
    if nrs > 0
        disp([dispNm ' relaxed non-negativity constraints ' ...
            'and bounds for ' num2str(nrs) ' timepoint(s).']);
    end

    % add noise
    nis = 0;
    if ~opts.fitInLatent && opts.addSpikeNoise
        U0 = U;
        if strcmpi(opts.noiseDistribution, 'gaussian')
            U = normrnd(U0, repmat(sigma, nt, 1));
        elseif strcmpi(opts.noiseDistribution, 'poisson')
            U = poissrnd(max(U0,0));
        else
            error('Invalid noise distribution');
        end
        if numel(lb) == 0
            lb = -inf(1, nu);
        end
        if numel(ub) == 0
            ub = inf(1, nu);
        end
        lbs = repmat(lb, nt, 1);
        ubs = repmat(ub, nt, 1);
        
        c = 0;
        ixBad = any(U < lbs, 2) | any(U > ubs, 2);
        while sum(ixBad) > 0 && c < opts.nReps
            nBad = sum(ixBad);
            if strcmpi(opts.noiseDistribution, 'gaussian')
                U(ixBad,:) = normrnd(U0(ixBad,:), repmat(sigma, nBad, 1));
            elseif strcmpi(opts.noiseDistribution, 'poisson')
                U(ixBad,:) = poissrnd(max(U0(ixBad,:),0));
            end
            ixBad = any(U < lbs, 2) | any(U > ubs, 2);
        end
        nis = sum(ixBad);
    end
    if nis > 0
        disp([dispNm ' could not add noise to ' num2str(nis) ...
            ' timepoint(s)']);
    end 
    
    % count points out of bounds
    nlbs = 0; nubs = 0;
    if numel(lb) > 0
        nlbs = sum(any(U < repmat(lb, nt, 1), 2));
    end
    if numel(ub) > 0
        nubs = sum(any(U > repmat(ub, nt, 1), 2));
    end
    if nlbs > 0 || nubs > 0
        disp([dispNm ' hit lower bounds ' num2str(nlbs) ...
            ' time(s) and upper bounds ' num2str(nubs) ' time(s).']);
    end
    
    if opts.fitInLatent        
        Z = U;
        if opts.addSpikeNoise
            % project to spikes, then infer latents
            sps = tools.latentsToSpikes(Z, dec, true, true);
            Z = tools.convertRawSpikesToRawLatents(dec, sps');
        end
    else        
        if opts.obeyBounds && opts.nanIfOutOfBounds
            isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, true);
            ixOob = isOutOfBounds(U);
            U(ixOob,:) = nan;
        end
        out.U = U;
        Z = tools.convertRawSpikesToRawLatents(dec, U', ...
                opts.makeFAOrthogonal);
    end
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Zr = Te.latents*(RB2*RB2');
    Z = Z*(NB2*NB2') + Zr;
       
end

function m = findBestMean(Z, NB, gs, enforceNonneg)
% we want to minimize the mean null space error across groups
% to solve this, we calculate the mean null space activity per group, M
% and then find the closest null space mean, n, as follows:
%   n := argmin_n sum_i || n - M(i) ||_2
%          (sum is over grps)
%        = argmin_n sum_i n'*n - 2*n'*M(i) + const
%        = argmin_n = d*n'*n - 2*n'*sum(M)
%        = argmin_n = sum_j d*n_j^2 - 2*n_j*sum(M)_j
%      so this problem can be solved separately for each n_j
%        and setting the derivative equal to zero yields:
%            2*d*n_j - 2*sum(M)_j = 0 -> n_j = sum(M)_j/d
%     
    if nargin < 4
        enforceNonneg = true;
    end
    m = mean(grpstats(Z*NB, gs))*NB';
    if enforceNonneg
        % if we're in spike space, we also want NB*n >= 0
        % n.b. the below is not optimal, but in practice, the solution 
        % tends to obey our constraint anyway
        m = max(m, 0);
    end
end

