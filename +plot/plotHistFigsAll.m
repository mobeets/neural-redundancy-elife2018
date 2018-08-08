
% plot grid of hists
opts = struct('grpInds', 1:8, 'dimInds', 1:3, ...
    'doSave', doSave, 'doPca', true);
plot.plotHistFigs(fitName, runName, exampleSession, {}, opts);
