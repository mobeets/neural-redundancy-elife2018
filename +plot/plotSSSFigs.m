%% load SSS data (n.b. SSS = Steve's Special Space)
% for making plots as in Figure 6

if ~exist('plotExt', 'var')
    plotExt = 'png';
end
doSaveData = false;
exInds = [1 1]; % example session and angle indices (used below)
[errs, C2s, C1s, Ys, dts, hypnms, es] = plot.getSSS([fitName runName], ...
    exInds);

saveDir = fullfile('data', 'plots', runName, figureName);
if doSave && ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% plot average change in variance predicted by each hypothesis

mnkNms = {};
hypsToShow = hypnms;
cerrs = squeeze(nanmean(log(errs),2));
if numel(dts) > 1
    dtsc = dts(~all(isnan(cerrs),2));
    cerrs = cerrs(~all(isnan(cerrs),2),:); % drop nans if all in session
else
    dtsc = dts;
end
plot.plotSSSErrorFig(cerrs', hypnms, dtsc, mnkNms, ...
    hypsToShow, doSave, false, saveDir, [fitName '_avg'], ...
    doSaveData, runName, fitName, plotExt);

%% plot covariance ellipses of data for all sessions and velocity angles

width = numel(dts)*0.8;
hypClrs = [plot.hypColor('data'); [0.6 0.6 0.6]];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', width, 'height', 3, 'dstep', 6, 'XRotation', 0, ...
    'LineWidth', 2, 'dts', cellfun(@str2double, dts), ...
    'saveDir', saveDir, 'filename', [fitName '_data'], 'ext', plotExt);
plot.plotSSSEllipseFig(C1s, C2s(:,:,end), opts);

%% plot covariance ellipse of data for one session and velocity angle

hypClrs = [plot.hypColor('data'); 0.7*ones(1,3)];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'LineWidth', 3, ...
    'MarkerSize', 10, 'ext', plotExt, ...
    'saveDir', saveDir, 'filename', [fitName '_example']);
plot.plotSSSEllipseSingle(Ys{end-1}, Ys{end}, ...
    C1s{exInds(1), exInds(2)}, C2s{exInds(1), exInds(2), 6}, opts);
