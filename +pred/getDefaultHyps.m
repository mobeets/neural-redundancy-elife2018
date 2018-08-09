function hyps = getDefaultHyps(hnms, grpName)
% get all hypotheses by name (hnms: cell), and set the default parameters
% of each hypothesis as used in the manuscript
    if nargin < 1
        hnms = {};
    end
    if nargin < 2
        grpName = 'thetaActualGrps';
    end
    hyps = [];
    
    % params (most are for min-energy hyps only)
    fitInLatent = false; % fit in latent factor space or neural spike space
    addNoise = true; % when going from factor activity to spikes
    obeyBounds = true; % min/max firing rate constraints per channel
    nanIfOutOfBounds = true;
    nReps = 100; % number of tries to resample out-of-bounds points
    
    % Minimal Firing (L2 norm)
    clear hyp;
    hyp.name = 'minimal-firing';
    hyp.opts = struct('minType', 'minimum', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 2, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise, ...
        'nReps', nReps);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

    % Minimal Deviation
    clear hyp;
    hyp.name = 'minimal-deviation';
    hyp.opts = struct('grpName', grpName, 'addNoise', addNoise, ...
        'nReps', nReps, 'obeyBounds', obeyBounds, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.bestMeanFit;
    hyps = [hyps hyp];

    % Uncontrolled-uniform
    clear hyp;
    hyp.name = 'uncontrolled-uniform';
    hyp.opts = struct('obeyBounds', obeyBounds, 'nReps', nReps, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.uniformSampleFit;
    hyps = [hyps hyp];

    % Uncontrolled-empirical
    clear hyp;
    hyp.name = 'uncontrolled-empirical';
    hyp.opts = struct('obeyBounds', obeyBounds, 'nReps', nReps, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.randNulValFit;
    hyps = [hyps hyp];

    % Persistent Strategy
    clear hyp;
    hyp.name = 'persistent-strategy';
    hyp.opts = struct('thetaTol', 22.5, 'obeyBounds', obeyBounds, ...
        'nReps', nReps, 'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.randNulValInGrpFit;
    hyps = [hyps hyp];

    % Fixed Distribution
    clear hyp;
    hyp.name = 'fixed-distribution';
    hyp.opts = struct('kNN', nan, 'obeyBounds', obeyBounds, ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'nReps', nReps);
    hyp.fitFcn = @hypfit.closestRowValFit;
    hyps = [hyps hyp];

    % filter out unwanted hyps
    if ~isempty(hnms)
        hix = ismember({hyps.name}, hnms);
        hyps = hyps(hix);
    end
end
