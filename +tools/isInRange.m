function ix = isInRange(xs, bnds)
% check if the angles in xs [n x 1]
%    are within the angle range in bnds [2 x 1]
% returns ix [n x 1], vector of logicals
% 
    if bnds(1) <= bnds(2)
        ix = xs >= bnds(1) & xs <= bnds(2);
    else % e.g. [337.5 22.5]
        ix = xs >= bnds(1) | xs <= bnds(2);
    end
end
