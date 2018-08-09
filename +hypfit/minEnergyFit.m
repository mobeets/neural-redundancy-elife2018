function [Z,out] = minEnergyFit(Tr, Te, dec, opts)
% aka "Minimal Firing" (Figure 2A)
% 
% for each timestep in the test data (Te), finds the spiking activity with
% minimum norm such that we reproduce the observed output-potent activity
% subject to constraints on min/max firing per channel
% 
    if nargin < 4
        opts = struct();
    end
    defopts = struct('nanIfOutOfBounds', false, ...
        'noiseDistribution', 'poisson', 'pNorm', 2, 'nReps', 10, ...
        'obeyBounds', true, 'sigmaScale', 1.0, 'addSpikeNoise', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    dispNm = 'minimal-firing';
    
    Y1 = Tr.spikes;
    Y2 = Te.spikes;
    sigma = opts.sigmaScale*dec.spikeCountStd; % std deviation per channel
    
    % set upper and lower bounds of firing rate per channel
    if opts.obeyBounds
        lb = 1.0*min(Y1); ub = 1.0*max(Y1);
    else
        lb = []; ub = [];
    end
    
    % solve minimum-norm spiking problem for each timestep
    [nt, nu] = size(Y2);
    [U, isRelaxed] = hypfit.findAllMinNormFiring(Te, [], lb, ub, dec, ...
        nu, false, opts.pNorm);
    nrs = sum(isRelaxed);
    if nrs > 0
        disp([dispNm ' relaxed non-negativity constraints ' ...
            'and bounds for ' num2str(nrs) ' timepoint(s).']);
    end

    % add spiking noise (either gaussian or poisson)
    % resampling if necessary to obey firing rate constraints per channel
    nis = 0;
    if opts.addSpikeNoise
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
    
    % count points out of bounds or on bounds
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
    % set to nan if out of bounds
    if opts.obeyBounds && opts.nanIfOutOfBounds
        isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, true);
        ixOob = isOutOfBounds(U);
        U(ixOob,:) = nan;
    end
    out.U = U;
    
    % convert predictions back to factor activity
    Z = tools.convertRawSpikesToRawLatents(dec, U');
    NB2 = Te.NB;
    RB2 = Te.RB;
    Zr = Te.latents*(RB2*RB2'); % = actual potent activity
    Z = Z*(NB2*NB2') + Zr; % = true potent + predicted null
       
end
