%% init

runName = 'example';
hnms = {'minimal-deviation', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'persistent-strategy', 'fixed-distribution'};
% hnms = [hnms {'minimal-firing'}]; % skip by default because it's slow

savePlots = true;
plotExt = 'png'; % or 'pdf'
doOverwrite = false; % allow overwriting fits if they already exist
dts = tools.getDatesInDir;

%% fit WMP activity using Intuitive activity, with IME
% (as shown in main text, Figures 2 - 6)

saveDir = ['Int2Pert_yIme_' runName];
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);

%% fit WMP activity using Intuitive activity, without IME
% (as shown in Figure 5 - Figure supp 2, and Figure 6 - Figure supp 1)

saveDir = ['Int2Pert_nIme_' runName];
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);

%% fit Intuitive activity using WMP activity, with IME
% (as shown in Figure 5 - Figure supplement 3)

saveDir = ['Pert2Int_yIme_' runName];
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 2, 'testBlk', 1);
pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);

%% make all figures

plot.plotAll(runName, savePlots, plotExt);
