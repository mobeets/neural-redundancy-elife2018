function [errs, C2s, C1s, Ys, dts, hypnms, es] = getSSS(fitsName, inds)
% inds will return data at inds
    
    % load
    [~,Fs] = plot.getScoresAndFits(fitsName, tools.getDatesInDir);
    dts = {Fs.datestr};
    hypnms = [{Fs(1).fits.name} 'data'];
    
    % process
    covAreaFcn = @trace;
    errFcn = @(C, Ch) covAreaFcn(Ch)/covAreaFcn(C);

    grps = tools.thetaCenters;
    errs = nan(numel(Fs), numel(grps), numel(Fs(1).fits)+1);
    es = nan(numel(Fs), numel(grps), numel(Fs(1).fits)+1, 2);
    C1s = cell(numel(Fs), numel(grps));
    C2s = cell(numel(Fs), numel(grps), numel(Fs(1).fits)+1);
    Ys = cell(numel(Fs(1).fits)+2, 1); % last two are data
    for ii = 1:numel(Fs)
        F = Fs(ii);
        Y1 = F.train.latents;
        Y2 = F.test.latents;
        RB1 = F.train.RB;
        RB2 = F.test.RB;
        NB1 = F.test.NB;
        NB2 = F.test.NB;
        
        M0 = F.test.M0;
        M1 = F.test.M1;
        M2 = F.test.M2;        

        SS0 = (NB2*NB2')*RB1; % when activity became irrelevant
        [SSS,s,v] = svd(SS0, 'econ');
        
        % find velocity through intuitive mapping for binning
        % under the assumption that v_{t-1} = v_t
%         D = pred.loadSession(F.datestr);
%         dec = D.blocks(1).fImeDecoder;
%         A = dec.M1; B = dec.M2; c = dec.M0;
%         vs1 = nan(size(Y1,1),2);
%         for t = 1:size(Y1,1)
%             vs1(t,:) = (eye(size(A)) - A)\(B*Y1(t,:)' + c);
%         end
%         vs2 = nan(size(Y2,1),2);
%         for t = 1:size(Y2,1)
%             vs2(t,:) = (eye(size(A)) - A)\(B*Y2(t,:)' + c);
%         end
%         gs1 = tools.thetaGroup(tools.computeAngles(vs1), grps);
%         gs2 = tools.thetaGroup(tools.computeAngles(vs2), grps);

        if numel(grps) == 1
            gs1 = grps*ones(size(Y1,1),1);
            gs2 = grps*ones(size(Y2,1),1);
        else
            gs1 = tools.thetaGroup(F.train.thetas, grps);
            gs2 = tools.thetaGroup(F.test.thetas, grps);
        end
        spd1 = arrayfun(@(ii) norm(F.train.vel(ii,:)), 1:size(F.train.vel,1))';
        spd2 = arrayfun(@(ii) norm(F.test.vel(ii,:)), 1:size(F.test.vel,1))';

%         gs1 = F.train.thetaActualImeGrps;
%         gs2 = F.test.thetaActualImeGrps;
        
        getMovementGroup = @(z) tools.thetaGroup(tools.computeAngles(...
            bsxfun(@plus, M2*z, M0)'), grps);
        if numel(grps) > 1
%             gs1 = tools.thetaGroup(tools.computeAngles(Y1*RB2), grps);
%             gs2 = tools.thetaGroup(tools.computeAngles(Y2*RB2), grps);
            gs1 = getMovementGroup(Y1');
            gs2 = getMovementGroup(Y2');
        else
            gs1 = grps*ones(size(Y1,1),1);
            gs2 = grps*ones(size(Y2,1),1);
        end

        for jj = 1:numel(grps)
            ix1 = gs1 == grps(jj);
            ix2 = gs2 == grps(jj);
%             spdmin = prctile(spd2(ix2), 70);
%             spdmax = prctile(spd1(ix1), 30);
%             ix1 = ix1 & spd1 >= spdmin & spd1 <= spdmax;
%             ix2 = ix2 & spd2 >= spdmin & spd2 <= spdmax;
            if sum(ix1) == 1 || sum(ix2) == 1
                continue;
            end            
            C1 = nancov(Y1(ix1,:)*SSS);
            C1s{ii,jj} = C1;
            
            % bootstrap inds to match sample size per bin
%             nboots = 50;
%             n1 = sum(ix1);
%             n2 = sum(ix2);
%             n = min(n1,n2);
%             rs1 = randi(n1, n, nboots);
%             rs2 = randi(n2, n, nboots);
            
            for kk = 1:numel(F.fits)
                C2 = nancov(F.fits(kk).latents(ix2,:)*SSS);
                C2s{ii,jj,kk} = C2;
                errs(ii,jj,kk) = errFcn(C1, C2);
                es(ii,jj,kk,1) = covAreaFcn(C1);
                es(ii,jj,kk,2) = covAreaFcn(C2);
                
%                 errs(ii,jj,kk) = err_bootstrap(Y1(ix1,:)*SSS, ...
%                     F.fits(kk).latents(ix2,:)*SSS, errFcn, rs1, rs2);
                
                if ii == inds(1) && jj == inds(2)
                    Ys{kk} = F.fits(kk).latents(ix2,:)*SSS;
                end
            end
            C2 = nancov(Y2(ix2,:)*SSS);
            C2s{ii,jj,end} = C2;
            errs(ii,jj,end) = errFcn(C1, C2);
            es(ii,jj,end,1) = covAreaFcn(C1);
            es(ii,jj,end,2) = covAreaFcn(C2);
%             errs(ii,jj,end) = err_bootstrap(Y1(ix1,:)*SSS, ...
%                 Y2(ix2,:)*SSS, errFcn, rs1, rs2);
            if ii == inds(1) && jj == inds(2)
                Ys{end-1} = Y1(ix1,:)*SSS;
                Ys{end} = Y2(ix2,:)*SSS;
            end
        end
    end    
end

function err = err_bootstrap(Y1, Y2, errFcn, rs1, rs2)
    es = nan(size(rs1,2),1);
    for ll = 1:size(rs1,2)
        Y1c = Y1(rs1(:,ll),:);
        Y2c = Y2(rs2(:,ll),:);
        es(ll) = errFcn(nancov(Y1c), nancov(Y2c));
    end
    err = mean(es);
end

