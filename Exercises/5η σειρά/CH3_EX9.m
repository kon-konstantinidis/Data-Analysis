% Chapter 3 - Exercise 8
clc;
clear;
close all;

M = 100;
n = 10;
m = 12;
X = normrnd(0,1,[M n]);
Y = normrnd(0,1,[M m]);

%% (a)
xMean = mean(X,2);
yMean = mean(Y,2);
pairMeans = xMean - yMean;
% Known distribution method
pd = fitdist(pairMeans,'Normal');
res = paramci(pd);
CI_pairMeans = res(:,1);
% Bootstrap method
B=1000;
CI_pairMeans_bootstrap = bootci(B,@mean,xMean - yMean);
