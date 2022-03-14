% Chapter 4 - Exercise 3
clc;
close all;
clear;

%% (b)
meanV = 77.78;
stdV = 0.71;
meanI = 1.21;
stdI = 0.71;
meanf = 0.283;
stdf = 0.017;

M = 1000;
V = normrnd(meanV,stdV,1,M);
I = normrnd(meanI,stdI,1,M);
f = normrnd(meanf,stdf,1,M);
P = V.*I.*cos(f);
stdP = sqrt( I.*cos(f).*stdV + V.*cos(f).*stdI - V.*I.*sin(f).*stdf );
histogram(stdP);
title('Without correlation between f and V');
figure;
%% (c)
M=1000;
I = normrnd(meanI,stdI,1,M);
coef = [stdV^2 0.5*stdV*stdf;0.5*stdV*stdf stdf^2];
mvVals = mvnrnd([meanV meanf],coef,1);
V = mvVals(1);
f = mvVals(2);
P_c = V.*I.*cos(f);
stdP_c = sqrt( I.*cos(f).*stdV + V.*cos(f).*stdI - V.*I.*sin(f).*stdf );
histogram(stdP_c);
title('With correlation of 0.5 between f and V');