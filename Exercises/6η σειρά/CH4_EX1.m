% Chapter 4 - Exercise 1
clc;
close all;
clear;

%% (b)
M = 1000;
values = normrnd(58,2,[M 5]);
meanH2 = mean(values,2);
stdH2 = std(values')'; %#ok<UDIM>
eSample = sqrt(values./100);
histogram(eSample);
hold on;
plot([0.76 0.76],ylim,'r')
%% (c)
h1 = [80 100 90 120 95];
h2 = [48 60 50 75 56];
e_exp = sqrt(h2./h1);
stdH1 = std(h1);
stdH2 = std(h2);
std_e_exp = std(e_exp);
[test_h, test_p] = ttest(e_exp, 0.76)