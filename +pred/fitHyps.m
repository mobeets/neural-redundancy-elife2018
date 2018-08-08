function F = fitHyps(D, hyps)
% fit all hypothesis predictions
%
% D must have fields: datestr, train, test, simpleData.nullDecoder
%
% D.train and D.test must have fields:
%     - latents
%     - spikes
%     - NB, RB, M0, M1, M2
%     - thetas (for hab)
%     - vel, velNext (for min/bas)
%
% hyps is struct array with fields:
%     - name
%     - opts
%     - fitFcn 
%

    % save only the data critical for scoring
    F.datestr = D.datestr;
    F.train = D.train;
    F.test = D.test;
    F.dec = D.dec;
    
    % fit all hyp predictions
    for ii = 1:numel(hyps)
        F.fits(ii).name = hyps(ii).name;
        disp(['    Fitting ' hyps(ii).name]);
        F.fits(ii).opts = hyps(ii).opts;
        [F.fits(ii).latents, F.fits(ii).extra_info] = hyps(ii).fitFcn(...
            F.train, F.test, F.dec, F.fits(ii).opts);
    end
    
end
