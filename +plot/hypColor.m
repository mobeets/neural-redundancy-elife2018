function clr = hypColor(hypnm)

    clrs = [0.9569    0.4275    0.2627;
        0.8431    0.1882    0.1529;
        0.4000    0.7412    0.3882;
        0.1020    0.5961    0.3137;
        0.4549    0.6784    0.8196;
        0.2706    0.4588    0.7059];
    hypnms = {'minimal-firing', 'minimal-deviation', ...
        'uncontrolled-uniform', 'uncontrolled-empirical', ...
        'persistent-strategy', 'fixed-distribution'};
    inds = strcmpi(hypnm, hypnms);
    if any(inds)
        clr = clrs(inds,:);
    elseif strcmpi(hypnm, 'data')
        clr = [0 0 0];
    else
        clr = [0.5 0.5 0.5];
    end
    return;
end
