function err = meanErrorFcn(YNc, YN0, gs)
% for each cursor-target angle bin, find error in predicting mean
%    where error is the L2 norm in the 8-D output-null space
% YNc: matrix of true output-null activity [nsamples x 8]
% YN0: matrix of predicted output-null activity [nsamples x 8]
% gs: vector of the cursor-target angle group of each sample [nsamples x 1]
% 
    grps = sort(unique(gs));
    errs = nan(numel(grps),1);
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        errs(ii) = norm(nanmean(YNc(ix,:)) - nanmean(YN0(ix,:)));
    end
    err = nanmean(errs);
end
