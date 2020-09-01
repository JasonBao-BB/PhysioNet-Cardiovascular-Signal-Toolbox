%	OVERVIEW:
%       This basic demo will allow you to load an ECG file in matlab 
%       compatible wfdb format, detect the locations of the R peaks,
%       perform signal quality (SQI) analysis and plot the results.
%
%   OUTPUT:
%       A figure with the loaded ECG signal and detected peaks will be
%       generated
%
%   DEPENDENCIES & LIBRARIES:
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%   REFERENCE: 
%       Vest et al. "An Open Source Benchmarked HRV Toolbox for Cardiovascular 
%       Waveform and Interval Analysis" Physiological Measurement (In Press), 2018. 
%	REPO:       
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%   ORIGINAL SOURCE AND AUTHORS:     
%       Giulia Da Poian   
%	COPYRIGHT (C) 2018 
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

run(['..' filesep 'startup.m'])

% Where are the data, in this demo they are located in a subfolder
InputFolder = [pwd filesep 'TestData' filesep 'mitdb-Arrhythmia']; % path to the folder where you data are located
SigName = '200m';

% load the ecg signa using load (it loads a variable called val)
load([InputFolder filesep SigName]);
% the signal has two channels, from now on we will use just one 
ecg = val(1,:);
% Get sampling frequency Fs from header file
sigInfo = readheader([InputFolder filesep SigName '.hea']);
Fs = sigInfo.freq;
% time vector for visualization (in seconds)
tm = 0:1/Fs:(length(ecg)-1)/Fs;

% plot the signal
figure(1)
plot(tm,ecg);
xlabel('[s]');
ylabel('[mV]')


% Detection of the R-peaks using the jqrs.m function included in the
% toolbox, requires to set initialization parameters calling the
% InitializeHRVparams.m function

HRVparams = InitializeHRVparams('Demo');
% set the exact sampling frequency usign the one from the loaded signal
HRVparams.Fs = Fs;
% call the function that perform peak detection
r_peaks = jqrs(ecg,HRVparams);

% plot the detected r_peaks on the top of the ecg signal
figure(1)
hold on;
plot(r_peaks./Fs, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks')

%%%%%%%%%%%%%% COMMENTS %%%%%%%%%%%%%%
% Author Boyang Bao
% BMI 500 Homework
% Line up peaks and Estimate periodicity

%%%%%%%%%%%%%% LINE UP PEAKS %%%%%%%%%%%%%%
% Sample of signal in 1/2 second
sample = 0.5 * HRVparams.Fs;
% Create matrix of peaks
peaks_array = zeros(length(r_peaks) - 2, 2 * sample + 1);
% Draw the peaks
figure, hold on
title('Line Up Peaks');
xlabel('[s]');
xticks([0 sample 2 * sample + 1])
xticklabels({'0','0.5','1','1.5'})
ylabel('[mV]')
for i= 1 : length(r_peaks)-1
     peaks_array(i,:) = ecg(r_peaks(i) - sample : r_peaks(i) + sample);
     plot(peaks_array(i,:));
end

%%%%%%%%%%%%%% ESTIMATE THE PERIODICITY %%%%%%%%%%%%%%
% Calculate beats per second
difference = r_peaks(1 , 2 : end) ./ Fs - r_peaks(1,1:end-1) ./ Fs;
% Calculate average about the distance of contiguous peaks
tmp = (sum(difference) / length(difference));
% Calculate the periodicity
periodicity = 1 / tmp;%Estimated periodicity(HR(beats/sec)) is simply the inverse of an average over distance of contiguous peaks
% Print out
display(periodicity)


