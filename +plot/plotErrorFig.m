function [errs, dts, Ps] = plotErrorFig(fitName, runName, errNm, mnkNm, ...
    hypsToShow, doSave, doAbbrev, showYLabel, showMnkNm, errFloor, ...
    doSaveData, folderName)
    if nargin < 4
        mnkNm = '';
    end
    if nargin < 5
        hypsToShow = {};
    end
    if nargin < 6
        doSave = false;
    end
    if nargin < 7       
        doAbbrev = false; % abbreviate x-axis names
    end
    if nargin < 8
        showYLabel = true;
    end
    if nargin < 9
        showMnkNm = true; 
    end
    if nargin < 10
        errFloor = nan;
    end
    if nargin < 11
        doSaveData = doSave;
    end
    if nargin < 12
        folderName = 'ErrorFigures';
    end
    hypNmForSignificance = 'fixed-distribution';
    
    % if abbreviated, shorten figure
    if doAbbrev
        hght = 4;
    else
        hght = 5.5;
    end    
    
    % load scores
    S = plot.getScoresAndFits([fitName runName], tools.getDatesInDir);
    dts = {S.datestr};
    hypnms = {S(1).scores.name};
    hypDispNms = cellfun(@(h) plot.hypDisplayName(h, doAbbrev), ...
        hypnms, 'uni', 0);
    hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');

    % plot avg error
    if ~isempty(mnkNm)
        dtInds = tools.getMonkeyDateFilter(dts, {mnkNm});
    else
        dtInds = 1:numel(dts);
    end
    if ~isempty(hypsToShow)
        hypInds = cellfun(@(c) find(ismember(hypnms, c)), hypsToShow);
    else
        hypInds = 1:numel(hypnms);
    end
    if ismember(hypNmForSignificance, hypnms(hypInds))
        starBaseName = plot.hypDisplayName(hypNmForSignificance, doAbbrev);
    else
        starBaseName = '';
    end
    errs = plot.getScoreArray(S, errNm, dtInds, hypInds);
    
    if strcmpi(errNm, 'histError')
        errs = 100*errs;
        ymax = 105;
        lblDispNm = 'histograms (%)';
    elseif strcmpi(errNm, 'meanError')        
        errs = (1000/45)*errs;
        ymax = (1000/45)*16;
        lblDispNm = 'mean (spikes/s)';
    else
        lblDispNm = 'covariance (a.u.)';
        ymax = 11;
    end
    
    errsToSave = errs; errsToSave(any(isinf(errs),2),:) = nan;
    errs = errs(~any(isinf(errs),2),:);
    
    % no ylabel, shrink figure
    if ~showYLabel        
        ylbl = '';
        if doAbbrev
            wdth = 3.7;
        else
            wdth = 4;
        end
    else
        wdth = 4;
        ylbl = ['Error in ' lblDispNm];
    end
    if ~isempty(mnkNm) && showMnkNm
        mnkTitle = ['Monkey ' mnkNm(1)];
    else
        mnkTitle = '';
    end
    ttl = '';
    if ~isempty(mnkNm)
        fnm = [fitName '_' mnkNm(1) '_' errNm];
    else
        fnm = [fitName '_ALL_' errNm];
    end
    saveDir = fullfile('data', 'plots', runName, folderName);
    if doSave && ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    opts = struct('doSave', doSave, 'filename', fnm, ...
        'saveDir', saveDir, ...
        'width', wdth, 'height', hght, ...
        'doBox', true, ...
        'starBaseName', starBaseName, ...
        'ylbl', ylbl, ...
        'title', ttl, 'ymax', ymax, ...
        'TextNote', mnkTitle, ...
        'errFloor', errFloor, ...
        'clrs', hypClrs(hypInds,:));
    Ps = plot.plotError(errs, hypDispNms(hypInds), opts);
    if doSaveData
        saveDir = fullfile('data', 'plots', 'figures', runName, 'data');
        fnm = fullfile(saveDir, ['errs_' fitName '_' errNm '_' mnkNm '.csv']);
        writeCsvFile(errsToSave, errNm, hypDispNms, dts, fnm);
    end
end

function writeCsvFile(errs, errNm, hypDispNms, dts, fnm)
    mnkNms = cell(numel(dts), 1);
    for ii = 1:numel(dts)
        yr = dts{ii}(1:4);
        if strcmpi(yr, '2012')
            mnkNms{ii} = 'Jeffy';
        elseif strcmpi(yr, '2013')
            mnkNms{ii} = 'Lincoln';
        elseif strcmpi(yr, '2016')
            mnkNms{ii} = 'Nelson';
        end
    end
    hnms = strrep(hypDispNms, ' ', '_');
    hnms = strrep(hnms, '-', '_');
    T = array2table(errs, 'VariableNames', hnms);
    T.datestr = dts';
    T.errorMetric = repmat(errNm, numel(dts), 1);
    T.monkeyName = mnkNms;
    writetable(T, fnm);
end
