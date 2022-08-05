%% Dynamic Range Compressor (DRC) static IN-OUT curve measurement script, for 
%% GNU Octave (largely compatible with Matlab).
%%
%% Copyright (C) 2022 - Luca Novarini
%% 
%% This program is free software: you can redistribute it and/or modify it under
%% the terms of the GNU General Public License as published by the Free Software
%% Foundation, either version 3 of the License, or (at your option) any later
%% version.
%% 
%% This program is distributed in the hope that it will be useful, but WITHOUT 
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
%% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
%% details.
%% 
%% You should have received a copy of the GNU General Public License along with 
%% this program. If not, see <https://www.gnu.org/licenses/>.

clear all; close all; clc;

%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model = {'1176D'};          % '1176D', 'API2500', ...
ratio = [4, 8, 12, 20];     % [adim]
knee = {'Default'};         % 'Default', 'Hard', 'Soft', ...
trimSize = 10000;           % [samples]

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import OctaveLib.
addpath('./lib');

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

			% Calculate input signal envelope, exploiting the fact that its amplitude is constantly increasing.
			inputEnvelope = zeros(length(input) + 1, 1);
			for hh = 1:length(input)
				if (abs(input(hh)) > inputEnvelope(hh))
					inputEnvelope(hh + 1) = abs(input(hh));
				else
					inputEnvelope(hh + 1) = inputEnvelope(hh);
				end
			end
			inputEnvelope = fcn_LinToDb20(inputEnvelope((2 + trimSize):(end - trimSize)));
            
			% Calculate output signal envelope, exploiting the fact that its amplitude is constantly increasing.
			outputEnvelope = zeros(length(output) + 1, 1);
			for hh = 1:length(output)
				if (abs(output(hh)) > outputEnvelope(hh))
					outputEnvelope(hh + 1) = abs(output(hh));
				else
					outputEnvelope(hh + 1) = outputEnvelope(hh);
				end
			end
			outputEnvelope = fcn_LinToDb20(outputEnvelope((2 + trimSize):(end - trimSize)));
            
			% Compensate for any potential IN/OUT gain offset.
			offsetIndex = min(find(inputEnvelope >= (max(inputEnvelope) + min(inputEnvelope)) / 2));
			offset = inputEnvelope(offsetIndex) - outputEnvelope(offsetIndex);

			% Plot static curve.
			plot(inputEnvelope - offset, outputEnvelope, fcn_LineSpecByIndex(jj + kk - 1));
			
			% Append legend string for current plot to legend strings cell.
			legendStrings{jj + kk - 1} = sprintf('Ratio %d, Knee %s', ratio(jj), knee{kk});
		end
	end
	
	% Add plot legend.
	legend(legendStrings);
end
