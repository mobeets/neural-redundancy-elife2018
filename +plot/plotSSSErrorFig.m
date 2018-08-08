function plotSSSErrorFig(errs, hypnms, dts, mnkNms, ...
    hypsToShow, doSave, doAbbrev, saveDir, fnm, doSaveData, runName, fitName)
    if nargin < 4
        mnkNms = {};
    end
    if nargin < 5
        hypsToShow = {};
    end
    if nargin < 6
        doSave = false;
    end
    if nargin < 7
        doAbbrev = false;
    end
    if nargin < 8
        saveDir = 'data/plots';
    end
    if nargin < 9
        fnm = 'SSS_avg';
    end
    if nargin < 10
        doSaveData = doSave;
    end
    if nargin < 11
        runName = '';
    end
    if nargin < 12
        fitName = '';
    end

    hypDispNms = cellfun(@(h) plot.hypDisplayName(h, doAbbrev), ...
        hypnms, 'uni', 0);
    hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');

    % plot avg error
    if ~isempty(mnkNms)
        dtInds = io.getMonkeyDateFilter(dts, mnkNms);
        errs = errs(dtInds,:);
    end
    if ~isempty(hypsToShow)
        hypInds = ismember(hypnms, hypsToShow);
        hypDispNms = hypDispNms(hypInds);
        errs = errs(:,hypInds);
        hypClrs = hypClrs(hypInds,:);
    end

    opts = struct('clrs', hypClrs, 'showZeroBoundary', true, ...
        'ylbl', ['Change in variance (log ratio)' char(10) ...
        '\leftarrow Decrease     Increase \rightarrow'], ...
        'width', 4, 'height', 5.5, ...
        'doBox', false, 'starBaseName', '', 'ymin', -3, 'ymax', 3, ...
        'doSave', doSave, 'saveDir', saveDir, 'filename', fnm);
    plot.plotError(errs, hypDispNms, opts);
    if doSaveData
        saveDir = fullfile('data', 'plots', 'figures', runName, 'data');
        fnm = fullfile(saveDir, ['sss_' fitName '.csv']);
        writeCsvFile(errs, hypDispNms, dts, fnm);
    end
end

function writeCsvFile(errs, hypDispNms, dts, fnm)
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
    T.monkeyName = mnkNms;
    writetable(T, fnm);
end
