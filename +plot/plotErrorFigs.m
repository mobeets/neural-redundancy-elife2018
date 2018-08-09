% for plotting errors of each hypothesis
% in terms of histogram, mean, and covariance errors, as in Figure 5

hypsToShow = {};
doSaveData = false;
showYLabel = true;
showMnkNm = false;
doAbbrev = false;
if ~exist('plotExt', 'var')
    plotExt = 'png';
end
for ii = 1:numel(errNms)
    for jj = 1:numel(mnkNms)
        doAbbrev = ~strcmpi(mnkNms{jj}, 'Nelson');
        mnkNm = mnkNms{jj};
        if strcmpi(mnkNm, 'ALL')
            mnkNm = '';
        end
        plot.plotErrorFig(fitName, runName, errNms{ii}, ...
            mnkNm, hypsToShow, doSave, doAbbrev, showYLabel, showMnkNm, ...
            [], doSaveData, figureName, plotExt);
    end
end
