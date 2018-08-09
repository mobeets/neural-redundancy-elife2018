function [Z, inds] = randNulValInGrpFit(Tr, Te, dec, opts)
% aka "Persistent Strategy" (Figure 4A)
% 
% for each timestep in the test data (Te), sample from timesteps in
% the training data (Tr) with similar cursor-target angle (within thetaTol)
% and uses the output-null activity of the sample as the prediction.
% 
    if nargin < 4
        opts = struct();
    end
    defopts = struct('thetaTol', 22.5, 'obeyBounds', true, ...
        'nReps', 10, 'nanIfOutOfBounds', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Z1 = Tr.latents;
    Z2 = Te.latents;
    ths1 = Tr.thetas;
    ths2 = Te.thetas;
    
    % find timesteps in Train with similar cursor-target angles to Test
    % and then for each timestep, sample randomly among those timesteps
    dsThs = pdist2(ths2, ths1, @tools.angleDistance);
    ix = dsThs <= opts.thetaTol;
    [Zsamp, nErrs, inds] = getSamples(Z1, ix);
    
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
            [Zsamp, nErrs, newInds] = getSamples(Z1, ix(ixOob,:));
            inds(ixOob) = newInds;
            Z(ixOob,:) = Zr(ixOob,:) + Zsamp*(NB2*NB2');
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            disp(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' persistent-strategy sample(s) to lie within bounds']);
        end
        if sum(ixOob) > 0
            disp([num2str(sum(ixOob)) ' persistent-strategy sample(s) ' ...
                'still out-of-bounds']);
        end
        if opts.nanIfOutOfBounds
            Z(ixOob,:) = nan;
        end
    end
    if nErrs > 0
        disp([num2str(nErrs) ...
            ' persistent-strategy sample(s) had no neighbors within range.']);
    end
end

function [Zsamp, nZero, indsChosen] = getSamples(Z1, ix)
    nt = size(ix,1);
    nix = sum(ix,2);
    
    % if nothing is in range, sample from anything
    nZero = sum(nix == 0);
    ix(nix == 0,:) = true;
    
    nums = 1:size(ix,2);
    indsChosen = nan(nt,1);
    for t = 1:nt
        curInds = nums(ix(t,:));
        chosenInd = randi(numel(curInds),1);
        indsChosen(t) = curInds(chosenInd);
        assert(ix(t,indsChosen(t)));
    end
    Zsamp = Z1(indsChosen,:);
end
