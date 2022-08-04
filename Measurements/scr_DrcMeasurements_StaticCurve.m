clear all; close all; clc;

%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model = {'SslGComp'};
ratio = [4, 8, 12];

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each model,
for ii = 1:length(model)
	% Setup a new plot.
	figure(); hold on; grid on;
	plotTitle = sprintf('%s Static Curve', model{ii});
	title(plotTitle);
	xlabel('Input [dB]');
	ylabel('Output [dB]');

	% For each ratio,
	for jj = 1:length(ratio)
		% Generate measurement file name.
		filename = sprintf('./wav/%s_Attack_%d_Release_%d_Ratio_%d.wav', model{ii}, attack(jj), release(kk), ratio(hh));

% Import measurement recording.
[y Fs] = audioread('./wav/1176D_Ratio_4_Knee_Default.wav');
input  = y(:, 1);
output = y(:, 2);

% Find both input/output signals envelope.
pkg load signal;
inputLevelInDb = 20 * log10(abs(hilbert(input)));
inputLevelInDb = inputLevelInDb(10000 : end - 10000);
outputLevelInDb = 20 * log10(abs(hilbert(output)));
outputLevelInDb = outputLevelInDb(10000 : end - 10000);
offsetIndex = find(inputLevelInDb >= (max(inputLevelInDb) + min(inputLevelInDb)) / 2, 1, 'first');
offset = inputLevelInDb(offsetIndex) - outputLevelInDb(offsetIndex);

% Display signal and envelope.
plot(inputLevelInDb - offset, outputLevelInDb, '-r');

% Import measurement recording.
[y Fs] = audioread('./wav/1176D_Ratio_8_Knee_Default.wav');
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
plot(inputLevelInDb - offset, outputLevelInDb, '-g');

% Import measurement recording.
[y Fs] = audioread('./wav/1176D_Ratio_12_Knee_Default.wav');
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
plot(inputLevelInDb - offset, outputLevelInDb, '-b');

% Add plot legend.
legend('4','8','12');