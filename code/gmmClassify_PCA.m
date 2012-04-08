% Assume log-likelihood of a test sequence X being
% uttered by that speaker is:
% log P(X, θ_s) = SUM (t=1:T) log p(x_t; θ_s)

% Classify each of the test sequences in the Testing
% data set according to the most likely speaker, s':
% s' = argmax (s=1:S) log P(X;θ_s)

% gmmClassify should calculate and report the likelihoods of
% the five most likely speakers for each test utterance. Put
% these in files called unkn_N.lik for each test utterance N.

% dir_test: path to Testing directory
% gmms: struct created by gmmTrain
% M: number of Gaussians/mixture (integer)
% N: number of possible speakers
% output_dir: path to directory to output results (must already exist)
function gmmClassify( dir_test, gmms, M, S, output_dir, D, p )

	format long;
	D = 14;

	if nargin < 3
		M = 8;
	end
	if nargin < 4
		S = Inf;
	end
	if nargin < 5
		output_dir = 'lik';
	end
	if nargin < 6
		D = 14;
	end
	if nargin < 7
		p = 10;
	end

	unkn_mfccs = dir([dir_test, filesep, 'unkn*mfcc']);

	for N = 1:length(unkn_mfccs)

		disp(unkn_mfccs(N).name);

		% Read vectors in MFCC file.
		fid = fopen([dir_test, filesep, unkn_mfccs(N).name]);
		X = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [D Inf]);
		fclose(fid);

		% Transform data.
		X = pca(X', p);
		D = p;

		T = length(X);

		top = cell(1, 5);
		for y = 1: length(top)
			top{y} = struct('name', '', 'score', -Inf);
		end

		for s = 1:min(length(gmms), S)
			Theta = gmms{s};

			% Compute log-likelihood.
			LL = 0;   % P_X = SUM (t=1:T) log [ SUM (m=1:M) w_m*b_m(x) ]
			for t = 1:T
				x = X(:,t);
				p_x = 0;
				for m = 1:M
					p_x = p_x + Theta.weights(m) * exp(b_m_x(m, x, Theta, D));
				end
				LL = LL + log2(p_x);
			end

			% Maintain top5 ranking:
			y = length(top);
			while y > 0 && LL > top{y}.score
				y = y - 1;
			end
			ranking = y + 1;
			x = ranking;
			score = struct('name', Theta.name, 'score', LL);
			while x <= length(top)
				temp = top{x};
				top{x} = score;
				score = temp;
				x = x + 1;
			end


		end

		fp = fopen( [output_dir, filesep, regexprep(unkn_mfccs(N).name, '\.mfcc$', '.lik')], 'w' );
		fprintf(fp, '%s %f\n%s %f\n%s %f\n%s %f\n%s %f', top{1}.name, top{1}.score, top{2}.name, top{2}.score, top{3}.name, top{3}.score, top{4}.name, top{4}.score, top{5}.name, top{5}.score);
		fclose(fp);

	end

	

end