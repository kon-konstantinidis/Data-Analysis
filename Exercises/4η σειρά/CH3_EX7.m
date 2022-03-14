% Chapter 3 - Exercise 7
clc;
clear;
close all;
M = 100;
n = 10;
sampleMean = 0;
sampleSigma = 1;
sample = normrnd(sampleMean,sampleSigma,[M n]);
%% (a)

CIs_mean_known = zeros(M,2);
CIs_mean_bootstrap = zeros(M,2);
for i=1:M
    % Known distribution method
    pd = fitdist(sample(i,:)','Normal');
    res = paramci(pd);
    CIs_mean_known(i,:) = res(:,1);
    % Bootstrap method
    B=1000;
    CIs_mean_bootstrap(i,:) = bootci(B,@mean,sample(i,:));
end
% Plot CIs for each method
fa1 = figure();
histogram(CIs_mean_known(:,1),'FaceColor','b');
hold on;
histogram(CIs_mean_bootstrap(:,1),'FaceColor','r');
title(" For lower limit: \color{red}Bootstrap method (red)   \color{blue}Standard method (blue)");
fa2 = figure();
histogram(CIs_mean_known(:,2),'FaceColor','b');
hold on;
histogram(CIs_mean_bootstrap(:,2),'FaceColor','r');
title(" For upper limit: \color{red}Bootstrap method (red)   \color{blue}Standard method (blue)");

%% (b)
sample = exp(sample);
CIs_mean_known = zeros(M,2);
CIs_mean_bootstrap = zeros(M,2);
for i=1:M
    % Known distribution method
    pd = fitdist(sample(i,:)','exponential');
    res = paramci(pd);
    CIs_mean_known(i,:) = res(:,1);
    % Bootstrap method
    B=1000;
    CIs_mean_bootstrap(i,:) = bootci(B,@mean,sample(i,:));
end
% Plot CIs for each method
fb1 = figure();
histogram(CIs_mean_known(:,1),'FaceColor','b');
hold on;
histogram(CIs_mean_bootstrap(:,1),'FaceColor','r');
title(" For lower limit: \color{red}Bootstrap method (red)   \color{blue}Standard method (blue)");
fb2 = figure();
histogram(CIs_mean_known(:,2),'FaceColor','b');
hold on;
histogram(CIs_mean_bootstrap(:,2),'FaceColor','r');
title(" For upper limit: \color{red}Bootstrap method (red)   \color{blue}Standard method (blue)");