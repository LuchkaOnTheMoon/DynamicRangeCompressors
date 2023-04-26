%% Dynamic Range Compressor (DRC) static IN-OUT curve plotting script, for GNU 
%% Octave (largely compatible with Matlab).
%%
%% Copyright (C) 2022 - Luchika De Sousa
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

%%%% INPUT PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compressor settings
architecture = 0;           % 0 = Feed-forward, 1 = Feed-back.
kneeType = 0;               % 0 = Input-symmetric, 1 = Output-symmetric.
kneeWidth = 20;             % [dB]
ratio = 4;                  % [adim]
threshold = 0;              % [dB]

% Plot settings
minLevel = -40.0;           % [dB]
maxLevel = +40.0;           % [dB]
nPoints = 65536;            % [adim]

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input parameters check.
assert(maxLevel > minLevel);
assert(threshold >= minLevel);
assert(threshold <= maxLevel);
assert((architecture == 0) || (architecture == 1));
assert((kneeType == 0) || (kneeType == 1));
assert(kneeWidth >= 0.0);
assert(ratio >= 1.0);
assert(nPoints > 0);
assert(nPoints == int64(nPoints));

% Generate sidechain levels array.
sidechainLevelDbScale = linspace(minLevel, maxLevel, nPoints);

% Precompute some constants useful to speed up static curve computation.
a1 = architecture * (1 - ratio) + (1 - architecture) * (1 / ratio - 1);
a2 = not(xor(architecture, kneeType));
a3 = architecture * (1 - kneeType);
a4 = (1 - architecture) * kneeType;
a5 = kneeWidth * (ratio * (1 - architecture) * kneeType + architecture * (1 - kneeType) / ratio + a2);
a6 = kneeWidth / a1;

% For each sidechain level,
for ii = 1:nPoints
    % Precompute some variables useful to speed up static curve computation.
    a7 = sidechainLevelDbScale(ii) - threshold;

    % Hard Knee
    if (a7 <= 0)
        hardKneeGainLinScale(ii) = 0.0;
    else
        hardKneeGainLinScale(ii) = a1 * a7;
    end
    hardKneeGainLinScale(ii) = 10 ^ (hardKneeGainLinScale(ii) / 20);    
    
    % Soft Knee
    if (a7 <= -kneeWidth)
        softKneeGainLinScale(ii) = 0.0;
    elseif (a7 >= a5)
        softKneeGainLinScale(ii) = a1 * a7;
    else
        softKneeGainLinScale(ii) = a2 * (a1 * (a7 + kneeWidth) * (a7 + kneeWidth) / (4 * kneeWidth)) + ...
                                   a3 * (2 * a6 - kneeWidth + a7 + sqrt(4 * ratio * a6 * (a6 + a7))) + ...
                                   a4 * (-a7 + (2 * sqrt(kneeWidth * ((ratio - 1) * (a7 + kneeWidth) + kneeWidth)) - kneeWidth * (ratio + 1)) / (ratio - 1));
    end
    softKneeGainLinScale(ii) = 10 ^ (softKneeGainLinScale(ii) / 20);      
end

%%%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(); grid on; hold on;
title('Gain VS Input Level');
if (architecture > 0)
    plot(sidechainLevelDbScale - 20 * log10(softKneeGainLinScale), 20 * log10(softKneeGainLinScale), '-r', 'linewidth', 2);
    plot(sidechainLevelDbScale - 20 * log10(hardKneeGainLinScale), 20 * log10(hardKneeGainLinScale), '-g', 'linewidth', 2);
else
    plot(sidechainLevelDbScale, 20 * log10(softKneeGainLinScale), '-r', 'linewidth', 2);
    plot(sidechainLevelDbScale, 20 * log10(hardKneeGainLinScale), '-g', 'linewidth', 2);
end
xlabel('Input Level [dB]');
ylabel('Gain [dB]');

figure(); grid on; hold on;
title('DRC Static Curve');
if (architecture > 0)
    plot(sidechainLevelDbScale - 20 * log10(softKneeGainLinScale), sidechainLevelDbScale, '-r', 'linewidth', 2);
    plot(sidechainLevelDbScale - 20 * log10(hardKneeGainLinScale), sidechainLevelDbScale, '-g', 'linewidth', 2);
else
    plot(sidechainLevelDbScale, sidechainLevelDbScale + 20 * log10(softKneeGainLinScale), '-r', 'linewidth', 2);
    plot(sidechainLevelDbScale, sidechainLevelDbScale + 20 * log10(hardKneeGainLinScale), '-g', 'linewidth', 2);
end
xlabel('Input Level [dB]');
ylabel('Output Level [dB]');
