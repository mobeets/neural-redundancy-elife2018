function ds = angleDistance(d1, d2, ignoreSign)
% angular error between d1 and d2 (in degrees)
% if ignoreSign is true, error is absolute (i.e., between 0 and 180)
    if nargin < 3
        ignoreSign = true;
    end
    ds = mod((d1-d2 + 180), 360) - 180;
    if ignoreSign
        ds = abs(ds);
    end
end
