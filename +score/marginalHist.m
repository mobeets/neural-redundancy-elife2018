function Hs = marginalHist(Y, gs, Xs, nbins)
    if nargin < 4
        nbins = size(Xs{1},1);
    end
    grps = sort(unique(gs));
    ngrps = numel(grps);
    nfeats = size(Y,2);    
    Hs = cell(ngrps,1);
    
    if isempty(Xs)
        mns = min(Y); mxs = max(Y);
        xs0 = linspace(min(mns), max(mxs), nbins);
    end
    for jj = 1:ngrps
        Hs{jj} = nan(nbins, nfeats);
        for ii = 1:nfeats
            if isempty(Xs)
                xs = xs0;
            else
                xs = Xs{jj}(:,ii);
            end
            hs = singleMarginal(Y(grps(jj) == gs,ii), xs);
            Hs{jj}(:,ii) = hs;
        end
    end
end

function ysh = singleMarginal(Y, xs)
    [c,b] = hist(Y, xs);
    ysh = c./trapz(b,c);
end
