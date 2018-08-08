function err = covErr(D1, D2)
% Riemannian distance between the covariance matrices of D1 and D2
% 
% src: "A Metric for Covariance Matrices"
% http://www.ipb.uni-bonn.de/pdfs/Forstner1999Metric.pdf
%
% note: invariant under scaling and rotation,
%     but sensitive to rank-deficient matrices
%     (hence the 'qz' and 'real' below)
%
    if sum(~isnan(sum(D1,2))) < 2 || sum(~isnan(sum(D2,2))) < 2
        % need at least 2 pts to calculate covariance
        err = nan; return;
    end
    es = eig(nancov(D1), nancov(D2), 'qz'); % 'qz' for stability
    err = real(sqrt(sum(log(es).^2)));
end
