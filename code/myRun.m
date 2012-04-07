% HMM_file: Path to .mat file containing HMM structure
% dir_test: Path to Testing directory
% file_name: Path to file to save output to
function myRun(HMM_file, dir_test, D, file_name)

	if nargin < 3 || D > 14
		D = 14;
	end
	if nargin < 4
		file_name = regexprep(HMM_file, '^[.]*/?(.*)\.mat$', '$1.txt');
	end

	load(HMM_file);

	phn_files = dir([dir_test, filesep, '*phn']);

	correct = 0;
	total = 0;

	fp = fopen(file_name, 'w');

	for f = 1:length(phn_files)

		[Starts, Ends, Phns] = textread([dir_test, filesep,  phn_files(f).name], '%d %d %s', 'delimiter','\n');

		utterance = regexprep(phn_files(f).name, '\.phn$', '');

		fid = fopen([dir_test, filesep, utterance, '.mfcc']);
		X = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', [D Inf]);
		fclose(fid);

		for p = 1:length(Phns)

			Start = max(Starts(p)/128 + 1, 0);
			End = min(Ends(p)/128 + 1, length(X));
			phn = char(clean(Phns(p)));

			hmm_phns = fieldnames(HMM);
			best_LL = struct('phn', '', 'score', -Inf);
			for h = 1:length(hmm_phns)
				hmm_phn = hmm_phns{h};
				score = loglikHMM(HMM.(hmm_phn), X(:, Start:End));
				if score > best_LL.score
					best_LL.phn = hmm_phn;
					best_LL.score = score;
				end
			end

			if strcmp(best_LL.phn, phn)
				correct = correct + 1;
				out = ['Correct - Expected ', best_LL.phn, ', got ', phn];
			else
				out = ['Incorrect - Expected ', best_LL.phn, ', got ', phn];
			end
			disp(out);
			fprintf(fp, '%s\n', out);

			total = total + 1;

		end

		disp(['----- ', num2str(round(100*f/length(phn_files))), '% COMPLETE -----']);		


	end

	out = ['Percent Correct: ', num2str(100*correct/total)];
	disp(out);
	fprintf(fp, '%s\n', out);

	fclose(fp);


end


function s = clean(str)
	s = regexprep(str, 'h#', 'sil');
end

