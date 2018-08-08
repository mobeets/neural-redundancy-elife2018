function delta = computeAngle(u,v)
% Takes two vectors and computes the angle between them
% Angle is positive if second vector is rotated counter-clockwise from
% first vector

assert(length(u) == length(v))
assert(length(u) == 2)

u = u/norm(u);
v = v/norm(v);

thetaU = atand(u(2)/u(1));
thetaV = atand(v(2)/v(1));

if u(1) < 0 %|| (u(1) == 0 && u(2) < 0)
    thetaU = thetaU + 180;
elseif u(1) == 0
    if u(2) < 0
        thetaU = -90;
    elseif u(2) > 0
        thetaU = 90;
    else
        error('u is [0 0]')
    end
end

if v(1) < 0 %|| (v(1) == 0 && v(2) < 0)
    thetaV = thetaV + 180;
elseif v(1) == 0
    if v(2) < 0
        thetaV = -90;
    elseif v(2) > 0
        thetaV = 90;
    else
        error('v is [0 0]')
    end
end

delta = thetaV-thetaU;

if delta > 180
    delta = delta-360;
elseif delta < -180
    delta = delta+360;
end

if abs(delta)>180
    error('computeAngle not working properly.. should only return angles between -180 and 180');
end

end
