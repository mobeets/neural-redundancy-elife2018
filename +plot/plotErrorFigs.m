
hypsToShow = {};
doSaveData = false;
showYLabel = true;
showMnkNm = false;
doAbbrev = false;
for ii = 1:numel(errNms)
    for jj = 1:numel(mnkNms)
        if strcmpi(errNms{ii}, 'histError')
            showMnkNm = false;
        else
            showMnkNm = false;
        end
        if strcmpi(mnkNms{jj}, 'Nelson')
            doAbbrev = false;
        else
            doAbbrev = true;
        end
        if strcmpi(mnkNms{jj}, 'ALL')
            mnkNm = '';
            showYLabel = true;
            doAbbrev = false;
        else
            mnkNm = mnkNms{jj};
        end
        plot.plotErrorFig(fitName, runName, errNms{ii}, ...
            mnkNm, hypsToShow, doSave, doAbbrev, showYLabel, showMnkNm, ...
            [], doSaveData, figureName);
    end
end
