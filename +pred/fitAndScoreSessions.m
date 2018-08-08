function fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite)
    if nargin < 4
        hnms = {};
    end
    if nargin < 5 || isempty(dts)
        dts = tools.getDatesInDir;
    end
    if nargin < 6
        doOverwrite = false;
    end

    hyps = pred.getDefaultHyps(hnms, grpName);

    % init saveDir and save opts
    saveDir = fullfile('data', 'fits', saveDir);
    if ~doOverwrite && exist(saveDir, 'dir')
        error('Cannot fit because directory already exists.');
    elseif ~exist(saveDir, 'dir')
        mkdir(saveDir);
        save(fullfile(saveDir, 'opts.mat'), ...
            'grpName', 'opts', 'hyps', 'dts');
    end

    % fit sessions
    disp(['Fitting and scoring ' num2str(numel(dts)) ' sessions...']);
    for ii = 1:numel(dts)
        try
            disp(['Processing ' dts{ii} '...']);
            [F,~] = pred.fitSession(dts{ii}, hyps, grpName, opts);
            S = score.scoreAll(F, grpName); % score each hyp
            disp('---------');
        catch exception
            msgText = getReport(exception, 'basic'); % no stack trace
            warning(['Error for ' dts{ii} ': ' msgText]);
            continue;
        end

        fnm = fullfile(saveDir, [dts{ii} '_fits.mat']);
        snm = fullfile(saveDir, [dts{ii} '_scores.mat']);
        save(fnm, 'F');
        save(snm, 'S');
    end

end
