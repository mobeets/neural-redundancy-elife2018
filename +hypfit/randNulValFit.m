function [Z, E] = randNulValFit(Tr, Te, dec, opts)
% aka "Uncontrolled-empirical" (Figure 3D)
% 
% for each timestep in the test data (Te), sample from timesteps in
% the training data (Tr) and use the output-null activity of the sample
% as the prediction.
% 
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
    
    Zsamp = Z1(randi(size(Z1,1),size(Z2,1),1),:); % random samples
    Zr = Z2*(RB2*RB2'); % = actual potent activity
    Z = Zr + Zsamp*(NB2*NB2'); % = true potent + predicted null
    
    % check to ensure that all predictions are consistent with min/max
    % firing rates on every channel; if not, resample
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
                ' uncontrolled-uniform sample(s) to lie within bounds']);
        end
        if opts.nanIfOutOfBounds
            Z(ixOob,:) = nan;
        end
    end
    E = [];

end
