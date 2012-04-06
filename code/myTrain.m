% Using the interface functions initHMM, loglikHMM, and trainHMM in /u/cs401/A3
% ASR/code, write a simple scriipt, myTrain, that can be used to initialize and
% train continuous hidden Markov models for each phoneme in the data set.

% Note that each model is trained on all data of a specific phoneme
% across all speakers; hence these models will be speaker-independent.



function [HMM] = myTrain(dir_train, max_iter, M, Q, D, S)

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
	if nargin < 6 || S > speakers
		S = speakers;
	end

	file_name = ['HMM_M' num2str(M) '-Q' num2str(Q) '-S' num2str(S) '-D' num2str(D), '-I', num2str(max_iter), '.mat'];

	PHN_data = struct();

	for s = 1:S

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

