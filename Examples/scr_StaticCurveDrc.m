%% Dynamic Range Compressor (DRC) static IN-OUT curve plotting script, for GNU 
%% Octave (largely compatible with Matlab).
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

%%%% PLOT PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputRange = [-40; +40];	% [dB]
step = 0.1;                 % [dB]

%%%% DRC PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold = +20.0;          % [dB]
knee = 10.0;                % [dB]
ratio = 10.0;              	% 1:X

%%%% PROCESSING - DO NOT EDIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% PARAMETERS CHECK %%%%
assert(step > 0.0);
assert(knee >= 0.0);
assert(ratio >= 1.0);
assert(threshold >= inputRange(1));
assert(threshold <= inputRange(2));

%%%% STATIC CURVE GENERATION %%%%
% Gain calculation.
inputLevel = inputRange(1) : step : inputRange(2);
for ii = 1:length(inputLevel)
    if (inputLevel(ii) - threshold > knee / 2)
        gain(ii) = (threshold - inputLevel(ii)) * (1 - 1 / ratio);
    elseif (abs(inputLevel(ii) - threshold) <= knee / 2)
        gain(ii) = ((1 / ratio - 1) * ((inputLevel(ii) - threshold + knee / 2) ^ 2)) / (2 * knee);
    else
        gain(ii) = 0.0;
    end
end

% Output level calculation.
outputLevel = inputLevel + gain;

%%%% PLOT %%%%
% Find output level @ threshold.
thresholdIndex = min(find(inputLevel >= threshold));
outputThresholdLevel = outputLevel(thresholdIndex);

% Plot static curve + threshold sight.
figure(); hold on; grid on;
plot(inputLevel, outputLevel, '-r');
plot(inputRange, ones(length(inputRange), 1) .* outputThresholdLevel, '--b');
plot([threshold, threshold], inputRange, '--b');
title('DRC static IN/OUT curve');
xlabel('IN [dB]');
ylabel('OUT [dB]');
xlim(inputRange);
ylim(inputRange);
