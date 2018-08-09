function D = prepSession(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('useIme', false, 'mapNm', 'fDecoder', ...
        'mapNm_spikes', 'nDecoder', 'skipFreezePeriod', true, ...
        'thetaNm', 'thetas', 'velNm', 'vel', 'velNextNm', 'velNext', ...
        'trainBlk', 1, 'testBlk', 2, 'fieldsToAdd', []);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    if opts.useIme
        opts = replaceWithImeFields(opts);
    end
    
    % find train and test inds
    Tr = D.blocks(opts.trainBlk);
    Te = D.blocks(opts.testBlk);
    ixTr = true(size(Tr.vel,1),1);
    ixTe = true(size(Te.vel,1),1);
    
    % ignore freeze period activity in test set
    if opts.skipFreezePeriod
        ixTe = ixTe & ~Te.isFreezePeriod;
    end
    
    % make train and test structs
    D.train = prepToFit(Tr, ixTr, opts.trainBlk, opts);
    D.test = prepToFit(Te, ixTe, opts.testBlk, opts);

end

function opts = replaceWithImeFields(opts)
    opts.mapNm = 'fImeDecoder';
    opts.mapNm_spikes = 'nImeDecoder';
    opts.velNm = 'velIme';
    opts.velNextNm = 'velNextIme';
    opts.thetaNm = 'thetasIme';
end

function C = prepToFit(B, ix, blkInd, opts)
    C.latents = B.latents(ix,:);
    C.spikes = B.spikes(ix,:);
    
    % cursor-target info
    ths = B.(opts.thetaNm);
    C.thetas = ths(ix,:);
%     C.target = B.target(ix,:);
    
    % velocity info
    vels = B.(opts.velNm);
    velNexts = B.(opts.velNextNm);
    C.vel = vels(ix,:);
    C.velNext = velNexts(ix,:);
%     C.pos = B.pos(ix,:);
    
    % add mapping and nul/row bases
    curMpg = B.(opts.mapNm);
    C.NB = curMpg.NulM2;
    C.RB = curMpg.RowM2;
    C.M0 = curMpg.M0;
    C.M1 = curMpg.M1;
    C.M2 = curMpg.M2;
    C.M0_spikes = B.(opts.mapNm_spikes).M0;
    C.M1_spikes = B.(opts.mapNm_spikes).M1;
    C.M2_spikes = B.(opts.mapNm_spikes).M2;
    C.NB_spikes = B.(opts.mapNm_spikes).NulM2;
    C.RB_spikes = B.(opts.mapNm_spikes).RowM2;
    
%     C.time = B.time(ix);
%     C.trial_index = B.trial_index(ix);
    C.block_index = blkInd;
    
    if isempty(opts.fieldsToAdd)
        return;
    end
    for ii = 1:numel(opts.fieldsToAdd)
        fldNm = opts.fieldsToAdd{ii};
        vs = B.(fldNm);
        C.(fldNm) = vs(ix,:);
    end
end
