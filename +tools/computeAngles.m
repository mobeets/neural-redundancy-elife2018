function ths = computeAngles(vecs)
% returns ths [n x 1], angle (in degrees) for each row of vecs [n x 2]

    ths = nan(size(vecs,1),1);
    for t = 1:size(vecs,1)
        ths(t) = tools.computeAngle(vecs(t,:), [1; 0]);
    end
    ths = mod(ths, 360);

end
