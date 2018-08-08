function [Z, inds] = habFit(Tr, Te, dec, opts)
% aka cloud
% 
    if nargin < 4
        opts = struct();
    end
    defopts = struct('kNN', nan, 'obeyBounds', true, ...
        'nanIfOutOfBounds', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    RB1 = Tr.RB;
    Z1 = Tr.latents;
    Z2 = Te.latents;
    
    ix = pdist2(tools.computeAngles(Z2*RB2), ...
        tools.computeAngles(Z1*RB2), @tools.angleDistance) <= 30;

    ZrCur = Z1*RB1;
    Zsamp = nan(size(Z2));
    inds = nan(size(Z2,1),1);
    matnrm = @(A,B) sum(A.*B,2);
    
    dsClose = pdist2(Z2*RB2, ZrCur);    
    for t = 1:size(Z2,1)        
%         curInds = ix(t,:);
        dsCur = dsClose(t,:);
        [~,ix] = sort(dsCur);
        curInds = ix(1:50);
        
        % ZrCur won't match ZrGoal; need to scale
        ZrCur1 = ZrCur(curInds,:);
        ZrGoal = repmat(Z2(t,:)*RB2, size(ZrCur1,1), 1);
        c = matnrm(ZrGoal, ZrCur1)./matnrm(ZrCur1, ZrCur1);
        ZAdj = bsxfun(@times, Z1(curInds,:), c);
        ds = pdist2(Z2(t,:)*RB2, ZAdj*RB1);
        [~, ind] = min(ds, [], 2);
        Zsamp(t,:) = ZAdj(ind,:);
        inds(t) = ind;
    end

%     ds = pdist2(Z2*RB2, Z1*RB1); % nz2 x nz1
%     if isnan(opts.kNN)
%         [~, inds] = min(ds, [], 2);
%     else
%         % sample inds from kNN nearest neighbors
%         inds = sampleFromCloseInds(ds, opts.kNN);
%     end
%     Zsamp = Z1(inds,:);
%     ZrCur = Zsamp*RB2; % this won't match Z2*RB2; need to scale
%     ZrGoal = Z2*RB2;
%     
%     matnrm = @(A,B) sum(A.*B,2);
%     c = matnrm(ZrGoal, ZrCur)./matnrm(ZrCur, ZrCur);
%     Zsamp = bsxfun(@times, Zsamp, c);
    
    Zr = Z2*(RB2*RB2');
    Z = Zr + Zsamp*(NB2*NB2');
    
    if opts.obeyBounds && ~isnan(opts.kNN)
        % resample invalid points
        isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, false);
        ixOob = isOutOfBounds(Z);
        n0 = sum(ixOob);
        maxC = 10;
        c = 0;
        while sum(ixOob) > 0 && c < maxC
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
