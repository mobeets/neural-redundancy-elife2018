function hyps = getDefaultHyps(hnms, grpName)
    if nargin < 1
        hnms = {};
    end
    if nargin < 2
        grpName = 'thetaActualGrps';
    end
    hyps = [];
    
    % params (most are for min-energy hyps only)
    fitInLatent = false;    
    addNoise = true;
    obeyBounds = true;
    nanIfOutOfBounds = true;
    nReps = 100; % number of tries to resample out-of-bounds points
    
    % minimum (L2 norm)
    clear hyp;
    hyp.name = 'minimal-firing';
    hyp.opts = struct('minType', 'minimum', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 2, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise, ...
        'nReps', nReps);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

    % best-mean
    clear hyp;
    hyp.name = 'minimal-deviation';
    hyp.opts = struct('grpName', grpName, 'addNoise', addNoise, ...
        'nReps', nReps, 'obeyBounds', obeyBounds, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.bestMeanFit;
    hyps = [hyps hyp];

    % uncontrolled-uniform
    clear hyp;
    hyp.name = 'uncontrolled-uniform';
    hyp.opts = struct('obeyBounds', obeyBounds, 'nReps', nReps, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.uniformSampleFit;
    hyps = [hyps hyp];

    % uncontrolled-empirical
    clear hyp;
    hyp.name = 'uncontrolled-empirical';
    hyp.opts = struct('obeyBounds', obeyBounds, 'nReps', nReps, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.randNulValFit;
    hyps = [hyps hyp];

    % habitual-corrected
    clear hyp;
    hyp.name = 'persistent-strategy';
    hyp.opts = struct('thetaTol', 22.5, 'obeyBounds', obeyBounds, ...
        'nReps', nReps, 'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.randNulValInGrpFit;
    hyps = [hyps hyp];

    % constant-cloud
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
