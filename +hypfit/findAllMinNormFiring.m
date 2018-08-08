function [Zs, isRelaxed] = findAllMinNormFiring(Blk, mu, lb, ub, ...
    dec, nd, fitInLatent, pNorm, makeFAOrthogonal)
% 
% Each u(t) in U is solution (using quadprog) to:
%   min_u || u - mu ||_pNorm
%      s.t.
%         (1) x1 = A2*x0 + B2*u + c2
%         (2) lb <= u <= ub
% i.e.
%   min_u sum_i(w_i)
%      s.t.
%         (0a) w_i <= u_i - f_i for all i
%         (0b) w_i >= u_i - f_i for all i
%         (1)  Aeq*u = beq
%         (2)  lb <= u <= ub
%
    
    if nargin < 4
        lb = [];
        ub = [];
    end
    if nargin < 7
        nd = nan;
    end
    if nargin < 9
        pNorm = 2; % default: L2 norm
    end
    
    [mu, Aeq, beqs] = makeConstraints(mu, Blk, fitInLatent, dec, nd, ...
        makeFAOrthogonal);
    
    if pNorm == 1            
        Zs = minL1Norm(mu, Aeq, beqs, lb, ub);
        isRelaxed = false(size(Zs,1),1);
    else
        [Zs, isRelaxed] = minL2Norm(mu, Aeq, beqs, lb, ub);
    end
end

function [mu, Aeq, beqs] = makeConstraints(mu, Blk, fitInLatent, dec, ...
    nd, makeFAOrthogonal)

%     x0 = Blk.vel(t,:)';
%     x1 = Blk.velNext(t,:)';
%     Ac = Blk.M1;
%     Bc = Blk.M2;
%     cc = Blk.M0;    
%     Aeq = Bc;
%     beq = x1 - Ac*x0 - cc;
    
    % we just need to match the current output-potent value
    Aeq = Blk.M2;
    beqs = Aeq*Blk.latents';

    if isnan(nd)
        nd = size(Aeq, 2);
    end
    if isempty(mu)
        mu = zeros(nd, 1);
    end
    if ~fitInLatent
        % update Aeq,beq so that our spike solutions, after 
        % converting to inferred latents, satisfy the kinematics 
        % constraints under the mapping in latents
        [~, beta] = tools.convertRawSpikesToRawLatents(dec, ...
            zeros(1,nd), makeFAOrthogonal);
        muGlob = dec.spikeCountMean;
        Aeq = Aeq*beta;
        beqs = bsxfun(@plus, beqs, Aeq*muGlob');
    end
end

function Zs = minL1Norm(mu, Aeq, beqs, lb, ub)
    nd = numel(mu);
    f = [zeros(nd,1); ones(nd,1)]; % f'*x = sum(w)
    A = [eye(nd) -eye(nd); -eye(nd) eye(nd)];
    b = [mu; -mu]; % Ax <= b --> u - w <= mu, -u + w <= -mu
    lb_ = [lb -inf(1,nd)]; ub_ = [ub inf(1,nd)]; % lb <= u <= ub
    Aeq_ = [Aeq zeros(2,nd)];
    options = optimset('Algorithm', 'interior-point', ...
        'Display', 'off');
    
    nt = size(beqs,2);
    Zs = nan(nt, nd);
    for t = 1:nt
        if mod(t, 500) == 0
            disp([num2str(t) ' of ' num2str(nt)]);
        end
        % linprog:
        %    min_x f'*x --> sum(w)
        %       s.t. Ax <= b   --> w <= x - b, w >= x - b
        %            Aeq*x  = beq
        %            lb <= x <= ub
        %
        [zc, ~, exitflag] = linprog(f, A, b, Aeq_, beqs(:,t), ...
            lb_, ub_, [], options);
        Zs(t,:) = zc(1:nd);
        if ~exitflag
            warning('linprog optimization incomplete, but stopped.');
        end
    end     
end

function [Zs, isRelaxed] = minL2Norm(mu, Aeq, beqs, lb, ub)
    nd = numel(mu);
    H = eye(nd);
    options = optimset('Algorithm', 'interior-point-convex', ...
        'Display', 'off');
    A = []; b = [];
    
    nt = size(beqs,2);
    Zs = nan(nt, nd);
    isRelaxed = false(nt, 1);
    for t = 1:nt        
        if mod(t, 500) == 0
            disp(['Fitting timestep ' num2str(t) ' of ' num2str(nt)]);
        end
        [z, ~, exitflag] = quadprog(H, -mu, A, b, Aeq, beqs(:,t), ...
            lb, ub, [], options);
        if ~exitflag
            warning('linprog optimization incomplete, but stopped.');
        end
        % if failed, try again without non-negative constraint
        if isempty(z) && ~isempty(b)
            z = quadprog(H, f, [], [], Aeq, beq, [], [], [], options);
            isRelaxed(t) = ~isempty(z);
        end
        Zs(t,:) = z;
    end
end
