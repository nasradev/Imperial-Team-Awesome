% Cite: Flash and Hogan 1985 
% http://www.jneurosci.org/content/jneuro/5/7/1688.full.pdf
% equation 2
function output = min_jerk(xi, xf, t)
% Generate a minimum jerk trajectory from xi to xf.
% xi: starting position, 1x3 matrix
% xf: final position, 1x3 matrix
% t: the time vector, Nx1 matrix
% output: the generated trajectory, Nx3 matrix
d = t(end);
N = length(t);
a = repmat((xf - xi), N, 1);
b(:,1)= ((-10 * (t/d).^3 + 15 * (t/d).^4 - 6 * (t/d).^5)')' ;

output = repmat(xi, N, 1) + a .* b;
end