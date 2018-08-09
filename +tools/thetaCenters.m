function cens = thetaCenters(n)
% returns n evenly-spaced angles around a circle
%   e.g., n = 8 => 0, 45, ..., 315
    if nargin < 1
        n = 8;
    end
    rads = linspace(0, 2*pi, n+1);
    rads = rads(1:end-1);
    cens = rad2deg(rads)';
end
