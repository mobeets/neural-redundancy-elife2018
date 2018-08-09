function preprocessSessions()
% each block needs the following fields copied over:
    fldNms = {'latents', 'spikes', 'target', 'thetas', 'thetasIme', ...
        'vel', 'velNext', 'velIme', 'velNextIme', 'fDecoder', ...
        'nDecoder', 'fImeDecoder', 'nImeDecoder', 'pos', 'time', ...
        'trial_index', 'thetaActualGrps', 'thetaActualImeGrps'};

    baseDir = '/Users/mobeets/code/nullSpaceFits/data/sessions/preprocessed';
%     dts = tools.getDatesInDir(baseDir);
    dts = {'20120525', '20120530', '20131211', '20131218', ...
        '20160722', '20160727'};
    
    for ii = 1:numel(dts)
        dtstr = dts{ii};
        fnm_in = fullfile(baseDir, [dtstr '.mat']);        
        d = load(fnm_in); D = d.D;
        
        clear E;
        E.datestr = D.datestr;
        dec = D.simpleData.nullDecoder;
        clear newdec;
        newdec.spikeCountMean = dec.spikeCountMean;
        newdec.spikeCountStd = dec.spikeCountStd;
        newdec.FactorAnalysisParams = dec.FactorAnalysisParams;
        E.dec = newdec;
        
        fnm_out = fullfile('data', 'sessions', [dtstr '.mat']);
        for jj = 1:2
            B = D.blocks(jj);
            clear B2;
            B2.block_index = jj;
            for kk = 1:numel(fldNms)
                B2.(fldNms{kk}) = B.(fldNms{kk});
            end
            
            E.blocks(jj) = B2;
        end
        
        D = E;
        save(fnm_out, 'D');
    end
end
