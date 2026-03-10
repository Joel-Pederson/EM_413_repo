function out = tri_draw(a, c, b, n)
  % TRI_DRAW - Sample n values from a triangular distribution [a,b] with mode c
  %
  % Input arguments:
  % a - lower bound
  % c - mode (peak)
  % b - upper bound
  % n - number of samples
  %
  % Output arguments:
  % out - 1x1xn array of drawn samples
    u1 = rand(1, 1, n);
    u2 = rand(1, 1, n);
    cutoff = (c - a) / (b - a);
    mask = u2 < cutoff;
    out = zeros(1, 1, n);
    % Inverse-CDF sampling for left side (a to c)
    out(mask) = a + sqrt(u1(mask) .* (b - a) .* (c - a));
    % Inverse-CDF sampling for right side (c to b)
    out(~mask) = b - sqrt((1 - u1(~mask)) .* (b - a) .* (b - c));
end