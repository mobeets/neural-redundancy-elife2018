function plotHistFigs(fitName, runName, dt, hypNms, opts)
    if nargin < 5
        opts = struct();
    end
    defopts = struct('doSave', false, ...
        'saveExt', 'pdf', 'ymax', nan, 'rowStartInd', nan, ...
        'doPca', true, 'grpInds', 1:8, 'dimInds', 1:3, 'saveData', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    saveDir = fullfile('data', 'plots', runName, 'Figures2-4');
    saveDirData = fullfile('data', 'plots', runName, 'data');
    if opts.doSave && ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    if opts.saveData && ~exist(saveDirData, 'dir')
        mkdir(saveDirData);
    end
    opts.saveDir = saveDir;
    opts.saveDirData = saveDirData;

    % load output-null activity
    [S,F] = plot.getScoresAndFits([fitName runName], {dt});
    if isempty(hypNms)
        hypNms = {F.fits.name};
    end
    Sa = plot.getScoresAndFits([fitName runName], tools.getDatesInDir);
    errs = plot.getScoreArray(Sa, 'histError');
    errs = mean(errs(~any(isinf(errs),2),:));
    
    NB = F.test.NB;
    Y0 = F.test.latents;
    mu = nanmean(Y0*NB);
    if opts.doPca
        [coeff, ~] = pca(Y0*NB);
    else
        coeff = eye(size(mu,2));
    end
    opts.dimScale = 1000/45; % scale to sec (each timestep is 45 msec)
    
    ix = ~isnan(S.gs);
    YN0 = bsxfun(@plus, bsxfun(@minus, Y0(ix,:)*NB, mu)*coeff, mu);
    YNc = cell(numel(hypNms),1); 
    err = nan(numel(hypNms),1);
    for ii = 1:numel(hypNms)
        Yc = F.fits(strcmp({F.fits.name}, hypNms{ii})).latents(ix,:);
        YNc{ii} = bsxfun(@plus, bsxfun(@minus, Yc*NB, mu)*coeff, mu);
        err(ii) = errs(strcmp({S(1).scores.name}, hypNms{ii}));
    end

    useDataOnlyForRange = false; % false -> use data and preds to set range
    [Hs, Xs, ~] = score.histsFcn([YN0; YNc], ...
        S.gs(ix), useDataOnlyForRange);
    H0 = Hs{1}; Hs = Hs(2:end);
    [H0, Hs, xs, ymx] = filterHists(H0, Hs, Xs, opts);
    if isnan(opts.ymax)
        opts.ymax = ymx;
    end

    if numel(opts.grpInds) == 1 && numel(opts.dimInds) == 1
        plotSingleton(H0, Hs, xs, hypNms, fitName, opts);
    else
        plotGrid(H0, Hs, xs, hypNms, fitName, err, opts);
    end
end

function data = plotGrid(H0, Hs, xs, hypNms, fitName, err, opts)

    % plot hists
    opts.clr1 = plot.hypColor('data');    
    for jj = 1:numel(Hs)        
        Hc = Hs{jj};
        opts.clr2 = plot.hypColor(hypNms{jj});
%         ix = strcmp(hypNms{jj}, {S.scores.name});
%         opts.histError = 100*S.scores(ix).histError;
        opts.histError = 100*err(jj);
        plot.plotGridHistFig(H0, Hc, xs, opts);
        
        if opts.saveData
            hnm = plot.hypDisplayName(hypNms{jj}, false);
            fnm = fullfile(opts.saveDirData, ...
                ['hists_' fitName '-' hypNms{jj} '.csv']);
            writeCsvFile(xs, H0, Hc, hnm, fnm);
        end
        
        if opts.doSave
            fnm = [fitName '_marginalHist_' hypNms{jj}];
            export_fig(gcf, fullfile(opts.saveDir, ...
                [fnm '.' opts.saveExt]));
        end
    end
end

function writeCsvFile(bins, H0, Hc, hnm, fnm)
    ntrgs = size(H0,1);
    nbins = size(H0,2);
    ndims = size(H0,3);    
    
    trgs = repmat(tools.thetaCenters, 1, nbins, ndims);
    dims = permute(repmat((1:3)', 1, ntrgs, nbins), [2 3 1]);
    bins = repmat(bins', ntrgs, 1, ndims);
    
    ydata_observed = H0;
    ydata_predicted = Hc;
    
    hnm = strrep(strrep(hnm, ' ', '_'), '-', '_');
    D = [trgs(:) dims(:) bins(:) ydata_observed(:) ydata_predicted(:)];
    T = array2table(D, 'VariableNames', ...
        {'target', 'dimension', 'bin_center', 'data', 'predicted'});
    T.hypothesisName = repmat(hnm, size(D,1), 1);
    writetable(T, fnm);
end

function plotSingleton(hs1, Hs, xs, hypNms, fitName, opts)
    
    % plot and save all hists
    opts.clr1 = plot.hypColor('data');
    opts.title = ['Output-null activity, dim. ' num2str(opts.dimInds)];
%     opts.dimScale = opts.dimScales(opts.dimInds);
    for ii = 1:numel(Hs)
        hs2 = Hs{ii};
        opts.clr2 = plot.hypColor(hypNms{ii});
        opts.ymax = 0.3;
        if strcmpi(hypNms{ii}, 'persistent-strategy')
            opts.lbl1 = [0.9 0.2];
            opts.lbl2 = [-1.36 0.25];
        elseif strcmpi(hypNms{ii}, 'fixed-distribution')
            opts.lbl1 = [0.9 0.2];
            opts.lbl2 = [-1.5 0.25];
        elseif strcmpi(hypNms{ii}, 'minimal-firing')
            opts.lbl1 = [0.6 0.2];
            opts.lbl2 = [-7.5 0.27];
            opts.ymax = 0.4;
        elseif strcmpi(hypNms{ii}, 'minimal-deviation')
            opts.lbl1 = [3 0.1];
            opts.lbl2 = [1 0.27];
            opts.ymax = 0.4;
        elseif strcmpi(hypNms{ii}, 'uncontrolled-uniform')
            opts.lbl1 = [0.0 0.2];
            opts.lbl2 = [5 0.15];
        elseif strcmpi(hypNms{ii}, 'uncontrolled-empirical')
            opts.lbl1 = [0.6 0.2];
            opts.lbl2 = [4.5 0.1];
        end
        plot.plotSingleHistFig(hs1, hs2, xs, opts);        
        if opts.doSave
            fnm = [fitName '_marginalHistSingle_' hypNms{ii}];
            export_fig(gcf, fullfile(opts.saveDir, ...
                [fnm '.' opts.saveExt]));
        end
    end
end

function [H0a, Hsa, xs, ymx] = filterHists(H0, Hs, Xs, opts)
    xs = Xs{1}(:,1); % xs is the same everywhere anyway
    nx = numel(xs);

    % init to empty
    H0a = nan(numel(opts.grpInds), nx, numel(opts.dimInds));
    Hsa = cell(numel(Hs), 1);
    for jj = 1:numel(Hs)
        Hsa{jj} = H0a;
    end

    % fill with filtered hists
    ymx = -inf;
    for ii = 1:numel(opts.grpInds)
        H0a(ii,:,:) = H0{opts.grpInds(ii)}(:,opts.dimInds);
        ymx = max(ymx, nanmax(H0a(:)));
        for jj = 1:numel(Hs)
            Hsa{jj}(ii,:,:) = Hs{jj}{opts.grpInds(ii)}(:,opts.dimInds);
            ymx = max(ymx, nanmax(Hsa{jj}(:)));
        end
    end
end

