function [SE IE DE LEV_DIST] = Levenshtein(hypothesis, annotation_dir)
% Input:
%	hypothesis: The path to file containing the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses


	[Starts, Ends, HypSentences] = textread(hypothesis, '%d %d %s', 'delimiter','\n');

	ref_files = dir([annotation_dir, filesep, '*txt']);

	% These are the averages.
	SE = 0;
	IE = 0;
	DE = 0;
	LEV_DIST = 0;

	TotalRefWords = 0;

	H = length(HypSentences);
	for h = 1:H

		[s, e, RefSentence] = textread([annotation_dir, filesep, 'unkn_', num2str(h), '.txt'], '%d %d %s', 'delimiter','\n');
		HypSentence = HypSentences(h);

		RefWords = strsplit(' ', char(RefSentence));
		HypWords = strsplit(' ', char(HypSentence));

		N = length(RefWords);
		M = length(HypWords);

		R = zeros(N, M); % matrix of distances
		B = cell(N, M); % for backtracking


		for i = 1:size(R)
			for j = 1:length(R)
				if (i == 1 && j > 1) || (j == 1 && i > 1)
					R(i,j) = Inf;
				end
			end
		end

		for i = 2:N
			for j = 2:M

				extra_cost = 0;
				if ~strcmp(RefWords{i}, HypWords{j})
					extra_cost = 1;
				end

				Del = R(i-1,j) + 1;
				Sub = R(i-1,j-1) + extra_cost;
				Ins = R(i,j-1) + 1;
				R(i,j) = min(Del, min(Sub, Ins));

				if R(i,j) == Del
					B{i,j} = 'UP';
				elseif R(i,j) == Ins
					B{i,j} = 'LEFT';
				else
					B{i,j} = 'UPLEFT';
				end

			end
		end

		% Backtrack. Count insertion/substiution/deletion errors.
		[Hyp_SE, Hyp_IE, Hyp_DE] = BackTrack(B, N, M, RefWords, HypWords);

		Hyp_SE = Hyp_SE / N;
		Hyp_IE = Hyp_IE / N;
		Hyp_DE = Hyp_DE / N;
		Hyp_LEV_DIST = 100 * R(N,M) / N;


		% For debuging:
		disp(['HYP SENTENCE ', num2str(h)]);
		disp(['> #REF=', num2str(N), '; #HYP=', num2str(M) ,'; SE=', num2str(Hyp_SE), '; IE=', num2str(Hyp_IE), '; DE=', num2str(Hyp_DE), '; LEV_DIST=', num2str(Hyp_LEV_DIST)]);

		% Uncomment to calculate by normal mean:
		% SE = SE + Hyp_SE;
		% IE = IE + Hyp_IE;
		% DE = DE + Hyp_DE;
		% LEV_DIST = LEV_DIST + Hyp_LEV_DIST;

		% Use this for weighted mean:
		SE = SE + N*Hyp_SE;
		IE = IE + N*Hyp_IE;
		DE = DE + N*Hyp_DE;
		LEV_DIST = LEV_DIST + N*Hyp_LEV_DIST;

		TotalRefWords = TotalRefWords + N;

	end

	% Uncomment to calculate by normal mean:
	% SE = SE / H;
	% IE = IE / H;
	% DE = DE / H;
	% LEV_DIST = LEV_DIST / H;

	% Use this for weighted mean:
	SE = SE / TotalRefWords;
	IE = IE / TotalRefWords;
	DE = DE / TotalRefWords;
	LEV_DIST = LEV_DIST / TotalRefWords;

return

% Function to compute number of errors of each type.
% B = Backtracking matrix
% N = # Ref words
% M = # Hyp words
% REF = array of refererence words
% HYP = array of hypothesis words
function [SE IE DE] = BackTrack(B, N, M, REF, HYP)
	a = N;
	b = M;
	SE = 0;
	IE = 0;
	DE = 0;
	while a >= 1 && b >= 1
		if strcmp(B(a,b), 'UP')
			DE = DE + 1;
			a = a - 1;
		else if strcmp(B(a,b), 'LEFT')
			IE = IE + 1;
			b = b - 1;
		else  % UPLEFT
			if ~strcmp(REF{a}, HYP{b})
				SE = SE + 1;
			end 
			a = a - 1;
			b = b - 1;
		end
	end
end


