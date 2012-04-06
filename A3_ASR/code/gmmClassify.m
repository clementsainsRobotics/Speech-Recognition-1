% Assume log-likelihood of a test sequence X being
% uttered by that speaker is:
% log P(X, θ_s) = SUM (t=1:T) log p(x_t; θ_s)

% Classify each of the test sequences in the Testing
% data set according to the most likely speaker, s':
% s' = argmax (s=1:S) log P(X;θ_s)

% gmmClassify should calculate and report the likelihoods of
% the five most likely speakers for each test utterance. Put
% these in files called unkn_N.lik for each test utterance N.

% TODO: fix top 5 part.

function gmmClassify( dir_test, gmms, M )

	format long;
	D = 14;

	unkn_mfccs = dir([dir_test, filesep, 'unkn*mfcc']);

	for N = 1:length(unkn_mfccs)

		disp(unkn_mfccs(N).name);

		% Read vectors in MFCC file.
		fid = fopen([dir_test, filesep, unkn_mfccs(N).name]);
		X = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [D Inf]);
		fclose(fid);

		T = length(X);

		top = cell(1, 5);
		for y = 1: length(top)
			top{y} = struct('name', '', 'score', -Inf);
		end

		for s = 1:length(gmms)
			Theta = gmms{s};

			% Compute log-likelihood.
			LL = 0;   % P_X = SUM (t=1:T) log [ SUM (m=1:M) w_m*b_m(x) ]
			for t = 1:T
				x = X(:,t);
				p_x = 0;
				for m = 1:M
					p_x = p_x + Theta.weights(m) * b_m_x(m, x, Theta, D);
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

			%disp([Theta.name, num2str(LL)]);

		end

		% Save top 5 to unkn_N.lik
		
		A = {};
		y = 1;
		for i = 1:length(top)
			A{y} = top{i}.name;
			A{y+1} = num2str(top{i}.score);
			y = y + 2;
		end
		%disp(A);
		
		disp(char(A));
		disp('--------------------------------------------')

		fp = fopen( ['lik', filesep, regexprep(unkn_mfccs(N).name, '\.mfcc$', '.lik')], 'w' );
		fprintf(fp, '%s %f\n%s %f\n%s %f\n%s %f\n%s %f', top{1}.name, top{1}.score, top{2}.name, top{2}.score, top{3}.name, top{3}.score, top{4}.name, top{4}.score, top{5}.name, top{5}.score);
		fclose(fp);

	end

	

end