
% Calculate log(b_m(x))

function b = b_m_x(m, x, Theta, D)
	
	if nargin < 4
		D = 14;
	end

	mean_m = Theta.means(:,m);
	
	b = 0;
	for n = 1:D
		variance_inverse = Theta.cov(n,n,m) ^ -1;
		b = b - 0.5 * variance_inverse * x(n) ^ 2 + variance_inverse * mean_m(n) * x(n) - 0.5 * variance_inverse * mean_m(n) ^ 2;
	end
	b = b - D/2 * log2(2*pi) - 0.5 * det(Theta.cov(:,:,m));



	% ALTERNATIVE METHOD:

	% numerator_sum = 0;
	% for i = 1:D
	% 	numerator_sum = numerator_sum + (power(x(i), 2) - 2*x(i)*mean_m(i) + power(mean_m(i), 2)) / Theta.cov(i,i,m);
	% end

	% numerator = exp(-0.5*numerator_sum);
	% denominator = power(2*pi, D/2) * sqrt(det(Theta.cov(:,:,m)));

	% b = log(numerator / denominator);


end