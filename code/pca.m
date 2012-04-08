
% Function for computing Principal components analysis.

% data = the original data
% d = the new dimension
function [new_data] = pca(data, p)

	data_size = size(data);

	% Subtract the mean from the data dimensions. The mean is the average across each dimension.
	for n = 1:data_size(2)
		u = mean(data(:,n));
		for m = 1:size(data)
			data(m,n) = data(m,n) - u;
		end
	end

	% Calculate the covariance matrix.
	cov_data = cov(data);

	% Calculate the p most significant eigenvectors and eigenvalues of covariance matrix.
	[FeatureVector, D] = eigs(cov_data, p);

	new_data = FeatureVector' * data';

end