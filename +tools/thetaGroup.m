function grps = thetaGroup(xs, centers)
% bin angles in xs [n x 1] (in degrees) to the nearest angle in centers
% e.g., tools.thetaGroup([5 -5 40 320], tools.thetaCenters) == [0 0 45 315]
% 
    dfs = diff(centers)/2;
    theta_tol = dfs(1);
    assert(norm(dfs - theta_tol) < 1e-4);

    bnds = mod([centers - theta_tol centers + theta_tol], 360);

    grps = nan(size(xs,1),1);
    for ii = 1:size(bnds,1)
        grps(tools.isInRange(xs, bnds(ii,:))) = centers(ii);
    end

end
