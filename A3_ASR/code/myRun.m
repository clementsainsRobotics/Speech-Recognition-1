function myRun(HMM, dir_test, D, M, Q)

	% M = Mixtures per sequence
	% Q = States per sequence

	if nargin < 3 || D > 14
		D = 14;
	end

	if nargin < 4
		M = 8;
	end

	if nargin < 5
		Q = 3;
	end


	disp(['D=', num2str(D), '; M=', num2str(M), '; Q=', num2str(Q)]);

	phn_files = dir([dir_test, filesep, '*phn']);

	for f = 1:length(phn_files)

		[Starts, Ends, Phns] = textread([dir_test, filesep, speaker, filesep,  phn_files(f).name], '%d %d %s', 'delimiter','\n');

		utterance = regexprep(phn_files(f), '\.phn$', '');

		fid = fopen([dir_train, filesep, speaker, filesep, utterance, '.mfcc']);
		X = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [D Inf]);
		fclose(fid);

		for p = 1:length(Phns)

			Start = max(Starts{p}/128 + 1, 0);
			End = min(Ends{p}/128 + 1, length(X));
			phn = char(clean(Phns{p}));

			LL = loglikHMM(HMM, X(:, Start:End));

			disp(['Speaker: ', speaker, '; Utterance: ', utterance, '; Phoneme: ', phn, '; LL = ', num2str(LL)]);

		end			


	end

	disp('---------------------------------------')


end


function clean(str)
	return regexprep(str, '#h', 'sil');
end

