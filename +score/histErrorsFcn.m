function [errs, nbins] = histErrorsFcn(YNcs, YN0, gs, nbins)
% for each cursor-target angle bin, find error in predicting covariance
%    where error is based on generalized eigenvalues (see +score/covErr)
% YNc: matrix of true output-null activity [nsamples x 8]
% YN0: matrix of predicted output-null activity [nsamples x 8]
% gs: vector of the cursor-target angle group of each sample [nsamples x 1]
% nbins: numeric; # of bins of output-null activity in each dimension
% 
% if nbins is nan, chooses # of bins by cross-validation
% 
    if nargin < 4
        nbins = nan; % choose # of bins by cross-validation
    end
    
    % make histograms
    [Hs,~,nbins] = score.histsFcn([YN0; YNcs], gs, false, nbins);
    H0 = Hs{1}; Hcs = Hs(2:end);
    
    % score each hypothesis by taking average histogram error
    %    across groups and dims
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
% find error, which can range between 0 and 1
    lfcn = @(y,yh) sum(abs(y-yh))/2;
    assert(numel(hc) == numel(h0));
    err = lfcn(hc/sum(hc), h0/sum(h0));
end
