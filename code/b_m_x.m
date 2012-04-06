function b = b_m_x(m, x, Theta, D)
	
	if nargin < 4
		D = 14;
	end

	mean_m = Theta.means(:,m);
	
	% b = 0;
	% for n = 1:D
	% 	variance_inverse = 1 / Theta.cov(n,n,m);
	% 	b = b - (0.5 * power(x(n), 2) + mean_m(n) * x(n) - 0.5 * power(mean_m(n), 2)) / Theta.cov(n,n,m);
	% end
	% b = b - D/2 * log2(2*pi) - 0.5 * det(Theta.cov(:,:,m));

	% numerator_sum = 0;
	% for i = 1:D
	% 	numerator_sum = numerator_sum + (power(x(i) - mean_m(i), 2) / Theta.cov(i,i,m));
	% end

	numerator_sum = 0;
	for i = 1:D
		numerator_sum = numerator_sum + (power(x(i), 2) - 2*x(i)*mean_m(i) + power(mean_m(i), 2)) / Theta.cov(i,i,m);
	end

	numerator = exp(-0.5*numerator_sum);
	denominator = power(2*pi, D/2) * sqrt(det(Theta.cov(:,:,m)));

	b = numerator / denominator;


end