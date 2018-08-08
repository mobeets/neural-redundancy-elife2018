function [Z, E] = randNulValFit(Tr, Te, dec, opts)
% choose intuitive pt within thetaTol
    if nargin < 4
        opts = struct();
    end
    defopts = struct('obeyBounds', true, 'nReps', 10, ...
        'nanIfOutOfBounds', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Z1 = Tr.latents;
    Z2 = Te.latents;    
    
    Zsamp = Z1(randi(size(Z1,1),size(Z2,1),1),:);
    Zr = Z2*(RB2*RB2');
    Z = Zr + Zsamp*(NB2*NB2');
    
    if opts.obeyBounds
        % resample invalid points
        isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, false);
        ixOob = isOutOfBounds(Z);
        n0 = sum(ixOob);
        c = 0;
        while sum(ixOob) > 0 && c < opts.nReps
            Zsamp = Z1(randi(size(Z1,1),sum(ixOob),1),:);
            Z(ixOob,:) = Zr(ixOob,:) + Zsamp*(NB2*NB2');
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            disp(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' unconstrained sample(s) to lie within bounds']);
        end
        if opts.nanIfOutOfBounds
            Z(ixOob,:) = nan;
        end
    end
    E = [];

end
