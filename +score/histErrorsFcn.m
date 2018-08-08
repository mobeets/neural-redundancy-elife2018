function [errs, nbins] = histErrorsFcn(YNcs, YN0, gs, nbins)
    if nargin < 4
        nbins = nan;
    end
    % make histograms
    [Hs,~,nbins] = score.histsFcn([YN0; YNcs], gs, false, nbins);
    H0 = Hs{1}; Hcs = Hs(2:end);
    
    % score each hyp, as mean across grps and dims
    grps = sort(unique(gs));
    ndims = size(YN0,2);
    nhyps = numel(YNcs);
    errs = nan(nhyps,1);
    for ii = 1:numel(YNcs)
        Hc = Hcs{ii};
        curerrs = nan(numel(grps), ndims);
        for jj = 1:numel(grps)
            for kk = 1:ndims
                curerrs(jj,kk) = histErrorFcn(Hc{jj}(:,kk), H0{jj}(:,kk));
            end
        end
        errs(ii) = nanmean(curerrs(:));
    end
end

function err = histErrorFcn(hc, h0)
% ranges between 0 and 1
    lfcn = @(y,yh) sum(abs(y-yh))/2;
    assert(numel(hc) == numel(h0));
    err = lfcn(hc/sum(hc), h0/sum(h0));
end
