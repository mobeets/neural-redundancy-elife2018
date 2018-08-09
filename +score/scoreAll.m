function S = scoreAll(F, grpName)
% F: fits object
% grpName: str; fieldname containing the grouping values
%    (e.g., cursor-target angle)
%
% S is a score object:
%     S
%       grpName: 'thetaGrps'
%       gs: [5148x1 double]
%       grps: [8x1 double]
%       scores(:):
%         name: 'fixed-distribution'
%         meanError: 0.54
%         covError: 112.0
%         histError: 0.58
    
    gs = F.test.(grpName);
    ix = ~isnan(gs);
    
    % save info
    S.datestr = F.datestr;
    S.timestamp = datestr(datetime);
    S.grpName = grpName;
    S.gs = gs;
    S.ixGs = ix;
    S.grps = unique(gs(ix));
    
    % gather output-null activity
    YN0 = F.test.latents(ix,:)*F.test.NB;
    YNcs = cell(numel(F.fits),1);
    for ii = 1:numel(F.fits)
        YNcs{ii} = F.fits(ii).latents(ix,:)*F.test.NB;
    end
    
    % compute mean, cov, and hist errors per hypothesis
    gs = gs(ix);
    [histErrs, nbins] = score.histErrorsFcn(YNcs, YN0, gs);
    for ii = 1:numel(F.fits)
        S.scores(ii).name = F.fits(ii).name;
        S.scores(ii).meanError = score.meanErrorFcn(YNcs{ii}, YN0, gs);
        S.scores(ii).covError = score.covErrorFcn(YNcs{ii}, YN0, gs);
        S.scores(ii).histError = histErrs(ii);
        S.scores(ii).histError_nbins = nbins;
    end

end
