function cnts = thetaCenters(n)
    if nargin < 1
        n = 8;
    end

%     rads = 0:pi/4:2*pi-pi/4;
    rads = linspace(0, 2*pi, n+1);
    rads = rads(1:end-1);
    cnts = rad2deg(rads)';

end
