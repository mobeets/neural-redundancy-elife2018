function [Z, inds] = closestRowValFit(Tr, Te, dec, opts)
% aka "Fixed Distribution" (Figure 4D)
% 
% for each timestep in the test data (Te), finds the closest timestep in
% the training data (Tr) in terms of output-potent activity, and uses the
% output-null activity of that timestep as the prediction.
% 
    if nargin < 4
        opts = struct();
    end
    defopts = struct('kNN', nan, 'obeyBounds', true, ...
        'nanIfOutOfBounds', false, 'nReps', 10);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    NB2 = Te.NB;
    RB2 = Te.RB;    
    Z1 = Tr.latents;
    Z2 = Te.latents;
    
    % find nearest neighbors in training data,
    % in terms of output-potent activity (using euclidean distance)
    ds = pdist2(Z2*RB2, Z1*RB2); % nz2 x nz1    
    if isnan(opts.kNN)
        % take the nearest neighbor to select a timestep from training data
        [~, inds] = min(ds, [], 2);
    else
        % sample inds from kNN nearest neighbors        
        inds = sampleFromCloseInds(ds, opts.kNN);
    end
    Zsamp = Z1(inds,:); % = joint activity from training data
    Zr = Z2*(RB2*RB2'); % = actual potent activity
    Z = Zr + Zsamp*(NB2*NB2'); % = true potent + predicted null
    
    % check to ensure that all predictions are consistent with min/max
    % firing rates on every channel; if not, resample
    if opts.obeyBounds && ~isnan(opts.kNN)
        % resample invalid points
        isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, false);
        ixOob = isOutOfBounds(Z);
        n0 = sum(ixOob);
        c = 0;
        while sum(ixOob) > 0 && c < opts.nReps
            % set dists of oob points to inf, then resample
            xinds = 1:size(ds,1); xinds = xinds(ixOob)';
            ds(sub2ind(size(ds), xinds, inds(ixOob))) = inf;
            newInds = sampleFromCloseInds(ds(ixOob,:), opts.kNN);
            inds(ixOob) = newInds;
            Z(ixOob,:) = Zr(ixOob,:) + Z1(newInds,:)*(NB2*NB2');
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            disp(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' fixed-distribution sample(s) to lie within bounds']);
        end
        if sum(ixOob) > 0
            disp([num2str(sum(ixOob)) ' fixed-distribution sample(s) ' ...
                'still out-of-bounds']);
        end
        if opts.nanIfOutOfBounds
            Z(ixOob,:) = nan;
        end
    end

end

function inds = sampleFromCloseInds(ds, k)
    [~,ix] = sort(ds, 2);
    ix = ix(:,1:k);
    sampInd = randi(k, size(ds,1), 1);
    ixSamp = sub2ind(size(ds), 1:size(ds,1), sampInd');
    inds = ix(ixSamp)';
end
