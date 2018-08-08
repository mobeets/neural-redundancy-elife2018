function ds = angleDistance(d1, d2, ignoreSign)
    if nargin < 3
        ignoreSign = true;
    end
    ds = mod((d1-d2 + 180), 360) - 180;
    if ignoreSign
        ds = abs(ds);
    end
end
