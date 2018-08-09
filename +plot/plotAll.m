function plotAll(runName, doSave, plotExt)
% Generates figures using all fits from running fitAndPlotAll
% 
    if nargin < 2
        doSave = false; % used implicitly by plotting functions below
    end
    if nargin < 3
        plotExt = 'png'; % or 'pdf'
    end
    addpath(fullfile('export_fig')); % required to save pretty figures
    
    % Figures 2-4
    fitName = 'Int2Pert_yIme_';
    exampleSession = '20131218';
    if checkFitsExist(runName, fitName, 'Figures 2-4', exampleSession)
        plot.plotHistFigs(fitName, runName, exampleSession, ...
            struct('doSave', doSave, 'ext', plotExt));
    end
    
    % Figure 5
    fitName = 'Int2Pert_yIme_';    
    errNms = {'histError', 'meanError', 'covError'};
    mnkNms = {'ALL'};
    figureName = 'Figure5';
    if checkFitsExist(runName, fitName, figureName)
        plot.plotErrorFigs;
    end
    
    % Figure 5 - Figure supplement 1
    fitName = 'Int2Pert_yIme_';
    mnkNms = {'Jeffy', 'Lincoln', 'Nelson'};
    errNms = {'histError', 'meanError', 'covError'};
    figureName = 'Figure5-FigureSupplement1';
    if checkFitsExist(runName, fitName, figureName)
        plot.plotErrorFigs;
    end
    
    % Figure 5 - Figure supplement 2
    fitName = 'Pert2Int_yIme_';
    errNms = {'histError', 'meanError', 'covError'};
    mnkNms = {'ALL'};
    figureName = 'Figure5-FigureSupplement2';
    if checkFitsExist(runName, fitName, figureName)
        plot.plotErrorFigs;
    end
    
    % Figure 5 - Figure supplement 3
    fitName = 'Int2Pert_nIme_';
    errNms = {'histError', 'meanError', 'covError'};
    mnkNms = {'ALL'};
    figureName = 'Figure5-FigureSupplement3';
    if checkFitsExist(runName, fitName, figureName)
        plot.plotErrorFigs;
    end
    
    % Figure 6
    fitName = 'Int2Pert_yIme_';
    figureName = 'Figure6';
    if checkFitsExist(runName, fitName, figureName)
        plot.plotSSSFigs;
    end
    
    % Figure 6 - Figure supplement 1
    fitName = 'Pert2Int_yIme_';
    figureName = 'Figure6-FigureSupplement1';
    if checkFitsExist(runName, fitName, figureName)
        plot.plotSSSFigs;
    end

end

function v = checkFitsExist(runName, fitName, plotnm, dt)
% make sure fit files exist
    if nargin < 4
        dts = {};
    else
        dts = {dt};
    end
    S = plot.getScoresAndFits([fitName runName], dts);
    if isempty(S)
        v = false;
        warning(['Skipping ' plotnm ' because fits do not exist.']);
    else
        v = true;
    end
end
