function b = b_m_x(m, x, Theta, D)
	
	if nargin < 4
		D = 14;
	end

	mean_m = Theta.means(:,m);
	
	% for n = 1:D
	% 	variance_negsqrd = 1 / (Theta.cov(n,n,m) * Theta.cov(n,n,m));
	% 	b = b - 0.5 * variance_negsqrd * (x(n) * x(n)) + variance_negsqrd * mean_m(n) * x(n) - 0.5 * variance_negsqrd * (mean_m(n) * mean_m(n));
	% end
	% b = b - D/2 * log2(2*pi) - 0.5 * det(Theta.cov(:,:,m));

	numerator_sum = 0;
	for i = 1:D
		numerator_sum = numerator_sum + (power(x(i) - mean_m(i), 2) / Theta.cov(i,i,m));
	end

	numerator = exp(-0.5*numerator_sum);
	denominator = power(2*pi, D/2) * sqrt(det(Theta.cov(:,:,m)));

	b = numerator / denominator;


end