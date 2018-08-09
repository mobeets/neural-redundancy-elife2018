function Ps = addSignificanceStars(errs, baseCol, fig, starSize)
%
    if nargin < 3
        fig = gcf;
    end
    if nargin < 4
        starSize = 20;
    end
    alphas = [0.05 1e-2 1e-3]; % significance levels to mark: *, **, ***
    multCompCor = 'none'; % correction for multiple comparisons, if any
    
    [inds, lvls, Ps] = getSignificantDifferences(errs, baseCol, alphas, multCompCor);
    plot.sigstar(inds, lvls, 0, true);
    
    % edit star size
    h = findall(fig, 'Tag', 'sigstar_stars');
    for ii = 1:numel(h)
        set(h(ii), 'FontSize', starSize);
    end
    
end

function [inds, lvls, Ps] = getSignificantDifferences(errs, baseCol, alphas, multCompCor)
% returns something like {[5,6], [4,6], [3,6], [2,6], [1,6]}
    
    nd = size(errs,2);    
    Ps = nan(nd,1);
    for ii = 1:nd
        if ii == baseCol
            continue;
        end
        Ps(ii) = signrank(errs(:,ii), errs(:,baseCol), 'tail', 'right');
    end
    
    [Ps0,ix] = sort(Ps);
    rnk = 1:nd; rnk = rnk(ix)';
    ntests = nd-1;
    if strcmpi(multCompCor, 'bonf')
        % Bonferroni correction
        denom = ntests;
    elseif strcmpi(multCompCor, 'holm-bonf')
        % Holm-Bonferroni correction
        denom = (ntests+1-rnk);
    else
        % no correction
        denom = 1;
    end
    sigs = cell2mat(arrayfun(@(ii) Ps0 < alphas(ii)./denom, ...
        1:numel(alphas), 'uni', 0));
    assert(~any(sigs(baseCol,:)));
    sigs = bsxfun(@times, sigs, alphas);
    sigs(sigs == 0) = nan;
    
    % collect significant inds
    inds = {};
    lvls = [];
    for ii = 1:nd
        if ii == baseCol
            continue;
        end
        lvl = nanmin(sigs(ii,:));
        if ~isnan(lvl)
            inds = [inds [ii baseCol]];
            lvls = [lvls lvl];
        end
    end
end
