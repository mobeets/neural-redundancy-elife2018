%% load

doSaveData = false;
exInds = [4 1]; % from exInd, below
[errs, C2s, C1s, Ys, dts, hypnms, es] = plot.getSSS([fitName runName], exInds);

saveDir = fullfile('data', 'plots', runName, figureName);
if doSave && ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% plot avgs

mnkNms = {};
hypsToShow = hypnms;
cerrs = squeeze(nanmean(log(errs),2));
dtsc = dts(~all(isnan(cerrs),2));
cerrs = cerrs(~all(isnan(cerrs),2),:); % drop nans if all in session
plot.plotSSSErrorFig(cerrs, hypnms, dtsc, mnkNms, ...
    hypsToShow, doSave, false, saveDir, [fitName '_avg'], ...
    doSaveData, runName, fitName);

%% plot ellipses - data

hypClrs = [plot.hypColor('data'); [0.6 0.6 0.6]];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 3.5, 'height', 3, 'dstep', 6, 'XRotation', 0, ...
    'LineWidth', 2, 'dts', cellfun(@str2double, dts), ...
    'saveDir', saveDir, 'filename', [fitName '_data']);
plot.plotSSSEllipseFig(C1s, C2s(:,:,end), opts);

%% plot example ellipse - data

hypClrs = [plot.hypColor('data'); 0.7*ones(1,3)];
% hypClrs = [plot.hypColor('data'); plot.hypColor('constant-cloud')];

opts = struct('clrs', hypClrs, 'doSave', doSave, 'LineWidth', 3, ...
    'MarkerSize', 10, ...
    'saveDir', saveDir, 'filename', [fitName '_example']);
plot.plotSSSEllipseSingle(Ys{end-1}, Ys{end}, ...
    C1s{exInds(1), exInds(2)}, C2s{exInds(1), exInds(2), 6}, opts);
