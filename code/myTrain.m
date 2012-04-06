% Using the interface functions initHMM, loglikHMM, and trainHMM in /u/cs401/A3
% ASR/code, write a simple scriipt, myTrain, that can be used to initialize and
% train continuous hidden Markov models for each phoneme in the data set.

% Note that each model is trained on all data of a specific phoneme
% across all speakers; hence these models will be speaker-independent.

% myTrain must use the same HMM format as initHMM and trainHMM. Once you have trained
% the models, write a script myRun that collects all phoneme sequences from the
% test data given their respective *.phn files. myRun must find the log
% likelihood of each phoneme sequence in the test data given each HMM phoneme
% model using the loglikHMM function. Report in your discussion on the
% proportion of correct identifications of the phoneme sequences in the test
% data.


% The array 'data' holds all the instances (sequences) for a particular phoneme
% over all utterances from all speakers. You'd have one 'data' array for /f/,
% another for /ah/, and so on.
 
% So here we are, looping over all Speakers and within that loop we're looping
% over all *.phn files in their directories. We open a *phn file and then go
% line-by-line in that file.
 
% For example, imagine that we have an /iy/ from sample 0 to sample 1,280. We
% need to make a copy of the relevant frames from the mfcc file (those frames
% are (0/128+1) to (1280/128+1) -- 1 to 11. We just copy the first 11 frames
% from the appropriate *.mfcc file -- that is a complete example of /iy/
% consisting of 11 frames.
 
% We now append that data (the transpose of that matrix) into 'data'. If this is
% the first time we've seen a /iy/ in our loops, that sequence is in data(1). If
% it's the second time we've seen /iy/ (regardless of whether it's in the same
% file or the same speaker), we put that sequence in data(2). And so on.



function [HMM] = myTrain(dir_train, max_iter, M, Q, D, N)

	if nargin < 2
		max_iter = 5;
	end
	if nargin < 3
		M = 8;
	end
	if nargin < 4
		Q = 3;
	end
	if nargin < 5
		D = 14;
	end
	
	speaker_dirs = dir([dir_train, filesep, '*0']);
	speakers = length(speaker_dirs);
	if nargin < 6 || N > speakers
		N = speakers;
	end

	file_name = ['HMM_M' num2str(M) '-Q' num2str(Q) '-N' num2str(N) '-D' num2str(D), '-I', num2str(max_iter), '.mat'];

	PHN_data = struct();

	for s = 1:speakers

		speaker = speaker_dirs(s).name;

		phn_files = dir([dir_train, filesep, speaker, filesep, '*phn']);

		for f = 1:length(phn_files)

			[Starts, Ends, Phns] = textread([dir_train, filesep, speaker, filesep,  phn_files(f).name], '%d %d %s', 'delimiter','\n');
			mfcc_file = regexprep(phn_files(f).name, 'phn$', 'mfcc');

			fid = fopen([dir_train, filesep, speaker, filesep, mfcc_file]);
			X = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [D inf]);
			fclose(fid);
			X_size = length(X);

			for p = 1:length(Phns)

				Start = max(Starts(p)/128 + 1, 0);
				End = min(Ends(p)/128 + 1, X_size);
				phn = char(clean(Phns(p)));

				if ~isfield(PHN_data, phn)
					PHN_data.(phn) = {};
				end

				PHN_data.(phn){length(PHN_data.(phn))+1} = X(:, Start:End);


			end

		end

	end

	save( 'PHN_data.mat', 'PHN_data', '-mat' ); 

	HMM = struct();

	f = fieldnames(PHN_data);
	for i = 1:length(f)
		phn = f{i};

		HMM.(phn) = initHMM( PHN_data.(phn), M, Q );

		disp(['Training HMM for ', phn])
		[HMM.(phn), LL] = trainHMM( HMM.(phn), PHN_data.(phn), max_iter );

		disp([num2str(100*i/length(f)),'% complete'])

	end

	save(file_name, 'HMM', '-mat'); 
	

end

function s = clean(str)
	s = regexprep(str, 'h#', 'sil');
end

