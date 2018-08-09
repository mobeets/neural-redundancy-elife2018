function h = optimalBinCount(Y, gs, minBinSz)
% for each group, for each column, calculate LOO c-v score for histogram
%   for a range of bin counts
% now, take the median of the z-scores of these scores across columns
%   and then take the mean of these resulting scores across groups
% returns the bin count minimizing the above score
%
% c-v score sources:
%  * http://toyoizumilab.brain.riken.jp/hideaki/res/histogram.html
%  * http://www.utdallas.edu/epps/statbook/apps/histogram.php
%
    if nargin < 3
        minBinSz = 10;
    end

%     crit = @(cs,h,n) 2./((n-1).*h) - sum(cs.^2)*(n+1)./((n-1)*n^2.*h);
    crit = @(cs,h,n) (2*mean(cs) - var(cs, 1))/h^2;
    hs = 1:200;
    
    grps = sort(unique(gs));
    sc = nan(numel(grps), numel(hs));
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        if sum(ix) == 1
            warning('Only one instance of group. Skipping in optimalBinCount.');
            continue;
        end
        Yc = Y(ix,:);        
        [nt, nd] = size(Yc);
        mny = min(Yc(:)); mxy = max(Yc(:));
        rng = mxy - mny;
        scs = nan(numel(hs), nd);
        for jj = 1:numel(hs)
            xs = linspace(mny, mxy, hs(jj));
            cs = hist(Yc, xs);
            for kk = 1:nd
                scs(jj,kk) = crit(cs(:,kk), rng/hs(jj), nt);
            end
        end
        sc(ii,:) = median(zscore(scs),2);
    end
    sc = nanmedian(sc);
    [~,ix] = min(sc);
    h = hs(ix);
    if ~isnan(minBinSz)
        h = max(h, minBinSz);
    end
end
