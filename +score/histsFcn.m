function [Hs, Xs, nbins] = histsFcn(Ys, gs, useFirstForRange, nbins)
% make histograms for Ys across a common range
%
% n.b. when making hists for display,
%   we will want to restrict range of Xs to only the first hyp,
%   also we want to have first rotated the NB via PCA for visualization
% 
    if nargin < 3
        useFirstForRange = false;
    end
    if nargin < 4 || isnan(nbins)
        nbins = score.optimalBinCount(Ys{1}, gs);
    end
    [Xs, rng] = getHistRange(Ys, nbins, gs, useFirstForRange);
    Hs = cell(numel(Ys),1);
    for ii = 1:numel(Ys)
        Hs{ii} = score.marginalHist(Ys{ii}, gs, Xs);
    end
end

function [Xs, rng] = getHistRange(Ys, nbins, gs, useFirstForRange)
    grps = sort(unique(gs));
    ngrps = numel(grps);
    ndims = size(Ys{1},2);
    
    % find range of points to include
    mns = min(min(Ys{1}));
    mxs = max(max(Ys{1})); % mns/mxs were the bounds used to choose nbins
    xs = linspace(mns, mxs, nbins);
    binspace = mode(diff(xs));
    if ~useFirstForRange
        for ii = 2:numel(Ys)
            mns = min(mns, min(min(Ys{ii})));
            mxs = max(mxs, max(max(Ys{ii})));
        end
        % must now increase xs to account for expanded range        
        while min(xs) > mns
            xs = [min(xs)-binspace xs];
        end
        while max(xs) < mxs
            xs = [xs max(xs)+binspace];
        end
    end
    rng = binspace*(numel(xs)-1); % range of bins
    
    % make cell array of bins repeated for each grp and dim
    Xs = cell(ngrps,1);
    for jj = 1:ngrps        
        Xs{jj} = nan(numel(xs), ndims);
        for ii = 1:ndims            
            Xs{jj}(:,ii) = xs;
        end
    end
end
