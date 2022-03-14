% Chapter 3 - Exercise 2

%% (a)
close all;
clc;
clear;
sampleSize = 100; % size of sample
lamda = 3; % actual value of lamda

% get n samples from Poisson distribution
samples = exprnd(lamda,1,sampleSize);
% Calculate samples' mean
samplesMean = mean(samples);
% Get the maximum likelihood estimation (MLE) of lamda
lamdaMLE = mle(samples,'distribution','exponential');
disp(' (a) ');
disp('Mean of samples is :');
samplesMean
disp('MLE of lamda is: ');
lamdaMLE

%% (b)
close all;
clc;
clear;
M = 500; % number of samples
n = 10000; % sample size
lamda = 18;

% Make an M(rows) x N(columns) matrix with the samples
allSamples = exprnd(lamda,M,n);
% Get mean of allSamples by row (mean of each sample)
allSamplesMean = mean(allSamples,2);
figure();
title('Mean of samples');
histogram(allSamplesMean);