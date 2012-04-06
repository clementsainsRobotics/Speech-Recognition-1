function gmms = gmmTrain( dir_train, max_iter, epsilon, M, D )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture

	format long;

	% Set default values if necessary.
	if nargin < 2
		max_iter = 50;
	end
	if nargin < 3
		epsilon = 0.001;
	end
	if nargin < 4
		M = 8;
	end
	if nargin < 5
		D = 14;
	end


	speaker_dirs = dir([dir_train, filesep, '*0']);
	gmms = cell(1, length(speaker_dirs)-2);  % subtract 2 to neglect links to current and parent directory 


	i = 1;
	while i < length(speaker_dirs)

		speaker_name = speaker_dirs(i).name;

		Theta = struct('name', speaker_name, 'weights', zeros(M, 1), 'means', zeros(D, M), 'cov', zeros(D, D, M));

		speaker_data_files = dir([dir_train, filesep, speaker_name, filesep, '*mfcc']);
		
		X = zeros(D, 1); 

		% Store all the speaker's training data in X.
		num_vectors = 1;
		for j = 1:length(speaker_data_files)

			% Read vectors in MFCC file.
			fid = fopen([dir_train, filesep, speaker_name, filesep, speaker_data_files(j).name]);
			data = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [D Inf]);
			fclose(fid);

			for d = 1:length(data)
				X(:, num_vectors) = data(:, d);
				num_vectors = num_vectors + 1;
			end

		end


		% Initialize Theta.
		for m = 1:M
			Theta.cov(:,:,m) = diag(ones(D,1),0);   % DxD identity matrix
			Theta.means(:,m) = X(:, randomInteger(1,num_vectors-1));   % random vector from speaker data
			Theta.weights(m) = 1 / M;
		end


		% E-M step.

		iteration = 0;
		prev_L = -Inf;
		improvement = Inf;

		T = length(X);

		while improvement >= epsilon && iteration <= max_iter

			% Compute log-likelihood.
			L = 0;

			% Keep track of all p_theta(x_t) for t=1..T
			P_thetas = zeros(T, 1);

			% Keep track of all computed values of b for each x.
			b_ms = zeros(M, T);

			for t = 1:T
				x = X(:,t);	

				P_theta = 0;
				for m = 1:M
					% Calculate b, given m and x.
					b_ms(m,t) = b_m_x(m, x, Theta, D);
					% P_theta += omega_m * b_m(x_t)
					P_theta = P_theta + (Theta.weights(m) * b_ms(m,t));
				end

				P_thetas(t) = P_theta;
				L = L + log2(P_theta);

			end

			% Update parameters.

			P_gamma_sums = cell(M, 3);

			for m = 1:M	
				for t = 1:T
					x = X(:,t);
					P_gamma = Theta.weights(m) * b_ms(m,t) / P_thetas(t);
					if t == 1
						P_gamma_sums{m,1} = P_gamma;
						P_gamma_sums{m,2} = P_gamma .* x;
						P_gamma_sums{m,3} = P_gamma .* (x .* x);
					else
						P_gamma_sums{m,1} = P_gamma_sums{m,1} + P_gamma;
						P_gamma_sums{m,2} = P_gamma_sums{m,2} + (P_gamma .* x);
						P_gamma_sums{m,3} = P_gamma_sums{m,3} + (P_gamma .* (x .* x));
					end
				end
			end
			for m = 1:M
				w_hat = P_gamma_sums{m,1} / T;
				mean_hat = P_gamma_sums{m,2} / P_gamma_sums{m,1};
				sigma_hat = P_gamma_sums{m,3} / P_gamma_sums{m,1} - (mean_hat .* mean_hat);

				Theta.weights(m) = w_hat;
				Theta.means(:,m) = mean_hat;
				Theta.cov(:,:,m) = diag(sigma_hat, 0);
			end

			improvement = L - prev_L;
			prev_L = L;
			iteration = iteration + 1;

		end

		gmms{i} = Theta;
		i = i + 1;

	end

	save( 'gmms', 'gmms', '-mat' ); 

end

function r = randomInteger(a, b)
	r = floor(a + (b-a+1) .* rand());
end

