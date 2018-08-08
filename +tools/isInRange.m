function ix = isInRange(xs, bnds)
    if bnds(1) <= bnds(2)
        ix = xs >= bnds(1) & xs <= bnds(2);
    else % e.g. [337.5 22.5]
        ix = xs >= bnds(1) | xs <= bnds(2);
    end
end
