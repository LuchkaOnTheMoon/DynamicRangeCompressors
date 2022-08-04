clear all; close all; clc;

%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model = {'1176D'};
ratio = [4, 8, 12, 20];
knee = {'Default'};

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import OctaveLib.
addpath('./lib');

% Load signal processing package (to access hilbert() function).
pkg load signal;

% For each model,
for ii = 1:length(model)
	% Open and setup a new figure.
	figure(); hold on; grid on;
	plotTitle = sprintf('%s Static Curve', model{ii});
	title(plotTitle);
	xlabel('Input [dB]');
	ylabel('Output [dB]');
	
	% Clean-up legend strings cell.
	legendStrings = {};

	% For each ratio,
	for jj = 1:length(ratio)
		% For each knee type,
		for kk = 1:length(knee)
			% Generate measurement file name.
			filename = sprintf('./wav/%s_Ratio_%d_Knee_%s.wav', model{ii}, ratio(jj), knee{kk});
			
			% Import measurement recording.
			[y, Fs] = audioread(filename);
			input  = y(:, 1);
			output = y(:, 2);

			% Find both input/output signals envelope.
			inputLevelInDb = 20 * log10(abs(hilbert(input)));
			inputLevelInDb = inputLevelInDb(10000 : end - 10000);
			outputLevelInDb = 20 * log10(abs(hilbert(output)));
			outputLevelInDb = outputLevelInDb(10000 : end - 10000);
			offsetIndex = find(inputLevelInDb >= (max(inputLevelInDb) + min(inputLevelInDb)) / 2, 1, 'first');
			offset = inputLevelInDb(offsetIndex) - outputLevelInDb(offsetIndex);

			% Display signal and envelope.
			plot(inputLevelInDb - offset, outputLevelInDb, fcn_LineSpecByIndex(jj + kk - 1));
			
			% Generate legend string for this plot.
			legendStrings{jj + kk - 1} = sprintf('Ratio %d, Knee %s', ratio(jj), knee{kk});
		end
	end
	
	% Add plot legend.
	legend(legendStrings);
end
