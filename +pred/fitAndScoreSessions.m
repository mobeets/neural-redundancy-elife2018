function fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite)
% for all sessions in dts (cell), and for all hypotheses in hnms (cell),
% generate fits using options in opts (struct), group data by grpName (str),
% and save fits in saveDir (str)
% 
% grpName refers to the fieldname that includes the cursor-target angle
%      bin for each time step (e.g., 0, 45, ..., 315 deg)
% 
    if nargin < 4
        hnms = {};
    end
    if nargin < 5 || isempty(dts)
        dts = tools.getDatesInDir;
    end
    if nargin < 6
        doOverwrite = false;
    end
    
    % get hypothesis fitting functions and default options
    hyps = pred.getDefaultHyps(hnms, grpName);

    % create saveDir and save the opts struct
    saveDir = fullfile('data', 'fits', saveDir);
    if ~doOverwrite && exist(saveDir, 'dir')
        error('Cannot fit because directory already exists.');
    elseif ~exist(saveDir, 'dir')
        mkdir(saveDir);
        save(fullfile(saveDir, 'opts.mat'), ...
            'grpName', 'opts', 'hyps', 'dts');
    end

    % fit all sessions
    disp(['Fitting and scoring ' num2str(numel(dts)) ' sessions...']);
    for ii = 1:numel(dts)
        try
            disp(['Processing ' dts{ii} '...']);
            % fit each hypothesis
            [F,~] = pred.fitSession(dts{ii}, hyps, grpName, opts);
            % score each hypothesis  in terms of mean, cov, and histograms
            S = score.scoreAll(F, grpName);
            disp('---------');
        catch exception
            msgText = getReport(exception, 'basic'); % no stack trace
            warning(['Error for ' dts{ii} ': ' msgText]);
            continue;
        end

        % save fits and scores
        fnm = fullfile(saveDir, [dts{ii} '_fits.mat']);
        snm = fullfile(saveDir, [dts{ii} '_scores.mat']);
        save(fnm, 'F');
        save(snm, 'S');
    end

end
