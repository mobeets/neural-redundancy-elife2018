function ths = computeAngles(vecs)

    ths = nan(size(vecs,1),1);
    for t = 1:size(vecs,1)
        ths(t) = tools.computeAngle(vecs(t,:), [1; 0]);
    end
    ths = mod(ths, 360);

end
