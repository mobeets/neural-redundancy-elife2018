function [bp, mu, sigma] = gauss2dcirc(data, sigMult, sigma)
% data [n x 2]
% plot(bp(1,:), bp(2,:)) will plot a circle
% 
    if nargin < 2
        sigMult = 1;
    end
    if nargin < 3
        assert(size(data,2)==2);
        mu = nanmean(data)';
        sigma = nancov(data);
    else
        mu = zeros(size(sigma,1),1);
    end    
    tt = linspace(0, 2*pi, 60)';
    x = cos(tt); y = sin(tt);
    ap = [x(:) y(:)]';
    [v,d] = eig(sigma);
    d = sigMult*sqrt(d);
    bp = (v*d*ap) + repmat(mu, 1, size(ap,2)); 

end
