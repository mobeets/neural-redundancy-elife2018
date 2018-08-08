function [Z, E] = uniformSampleFit(Tr, Te, dec, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('obeyBounds', true, 'nReps', 10, ...
        'nanIfOutOfBounds', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    RB = Te.RB;
    NB = Te.NB;
    Z1 = Tr.latents;
    Zr = Te.latents*(RB*RB');
    
    nt = size(Zr,1);
    Zn = getSamples(Z1*NB, nt);
    Z = Zr + Zn*NB';
    
    if opts.obeyBounds
        % resample invalid points
        isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, false);
        ixOob = isOutOfBounds(Z);
        n0 = sum(ixOob);
        c = 0;
        while sum(ixOob) > 0 && c < opts.nReps
            Zn = getSamples(Z1*NB, sum(ixOob));
            Z(ixOob,:) = Zr(ixOob,:) + Zn*NB';
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            disp(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' uniform sample sample(s) to lie within bounds']);
        end
        if opts.nanIfOutOfBounds
            Z(ixOob,:) = nan;
        end
    end
    E = [];

end

function Zsamp = getSamples(Z, n)
%
% generate n random samples of dim size(Z,2)
%   with the samples obeying the empirical
%   upper/lower bounds observed in Z
%
    mn = floor(min(Z));
    mx = ceil(max(Z));
    Zsamp = rand(n, size(Z,2)); % rand between 0 and 1
    Zsamp = bsxfun(@plus, mn, bsxfun(@times, (mx-mn), Zsamp));
    
end
