% Chapter 3 - Exercise 6
clc;
clear;
close all;
sampleSize = 10;
sampleMean = 0;
sampleSigma = 1;
sample = normrnd(sampleMean,sampleSigma,[1 sampleSize]);
%% (a)
B=1000;
bootstatMean = bootstrp(B,@mean,sample);
fa = figure();
histogram(bootstatMean);
xlabel("Mean value of sample according to bootstrap");
ylabel("Number of bootstrap records on each bin");
title("   (a)   ");
hold on;
axisSize = axis();
plot(mean(sample),1:axisSize(4),"r.",'MarkerSize',10);
%% (b)
stderrorFunc = @(x) std(x)/sqrt(length(x));
B=1000;
bootstatSE = bootstrp(B,stderrorFunc,sample);
fb = figure();
histogram(bootstatSE);
xlabel("Standard error of sample according to bootstrap");
ylabel("Number of bootstrap records on each bin");
title("   (b)   ");
hold on;
axisSize = axis();
plot(stderrorFunc(sample),1:axisSize(4),"r.",'MarkerSize',10);
%% (c)
clc;
clear;
sampleSize=10;
sampleMean = 0;
sampleSigma = 1;
sample = sampleMean + sampleSigma*rand(1,sampleSize);
sample = exp(sample);
% (a)
B=1000;
bootstatMean = bootstrp(B,@mean,sample);
fa = figure();
histogram(bootstatMean);
xlabel("Mean value of sample according to bootstrap");
ylabel("Number of bootstrap records on each bin");
title("   (a)   ");
hold on;
axisSize = axis();
plot(mean(sample),1:axisSize(4),"r.",'MarkerSize',10);
% (b)
stderrorFunc = @(x) std(x)/sqrt(length(x));
B=1000;
bootstatSE = bootstrp(B,stderrorFunc,sample);
fb = figure();
histogram(bootstatSE);
xlabel("Standard error of sample according to bootstrap");
ylabel("Number of bootstrap records on each bin");
title("   (b)   ");
hold on;
axisSize = axis();
plot(stderrorFunc(sample),1:axisSize(4),"r.",'MarkerSize',10);