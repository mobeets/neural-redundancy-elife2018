function [Z, inds] = closestRowValFit(Tr, Te, dec, opts)
% aka cloud
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
    
    ds = pdist2(Z2*RB2, Z1*RB2); % nz2 x nz1    
    if isnan(opts.kNN)
        [~, inds] = min(ds, [], 2);
    else
        % sample inds from kNN nearest neighbors        
        inds = sampleFromCloseInds(ds, opts.kNN);
    end
    Zsamp = Z1(inds,:);
    Zr = Z2*(RB2*RB2');
    Z = Zr + Zsamp*(NB2*NB2');
    
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
                ' cloud sample(s) to lie within bounds']);
        end
        if sum(ixOob) > 0
            disp([num2str(sum(ixOob)) ' cloud sample(s) ' ...
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
