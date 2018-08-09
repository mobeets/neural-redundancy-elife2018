function [F,D] = fitSession(dtstr, hyps, grpName, opts)
% fit each hypothesis in hyps (struct) to the provided session name (dtstr)
    if nargin < 3
        grpName = 'thetaActualGrps';
    end
    if nargin < 4
        opts = struct();
    end
    if ~isfield(opts, 'fieldsToAdd')
        opts.fieldsToAdd = {};
    end
    if ~ismember(grpName, opts.fieldsToAdd)
        opts.fieldsToAdd = [opts.fieldsToAdd grpName];
    end
    
    % load preprocessed session data
    d = load(fullfile('data', 'sessions', [dtstr '.mat'])); D = d.D;
    
    % split into train/test using opts; prepare for IME if we're using it
    D = pred.prepSession(D, opts);

    % fit hypotheses
    F = pred.fitHyps(D, hyps); % make predictions with each hyp

end
