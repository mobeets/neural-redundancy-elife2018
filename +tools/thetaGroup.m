function grps = thetaGroup(xs, centers)
    dfs = diff(centers)/2;
    theta_tol = dfs(1);
    assert(norm(dfs - theta_tol) < 1e-4);

    bnds = mod([centers - theta_tol centers + theta_tol], 360);

    grps = nan(size(xs,1),1);
    for ii = 1:size(bnds,1)
        grps(tools.isInRange(xs, bnds(ii,:))) = centers(ii);
    end

end
