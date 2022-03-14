% Chapter 3 - Exercise 4

%% (a) and (b)
close all;
clc;
clear;

sample = [41 46 47 47 48 50 50 50 50 50 50 50 48 50 50 50 50 50 50 50 52 52 53 55 50 50 50 50 52 52 53 53 53 53 53 57 52 52 53 53 53 53 53 53 54 54 55 68];
[H_b,P_b,CI_a] = vartest(sample,10000);
disp(' (a) ');
disp('95% confidence interval for the variance:');
CI_a
disp(' (b) ');
disp('Check hypothesis that 5kV is the standard deviation:');
H_b
P_b

%% (c) and (d)
close all;
clc;
clear;
sample = [41 46 47 47 48 50 50 50 50 50 50 50 48 50 50 50 50 50 50 50 52 52 53 55 50 50 50 50 52 52 53 53 53 53 53 57 52 52 53 53 53 53 53 53 54 54 55 68];
[H_d,P_d,CI_c] = ttest(sample,52);
disp(' (c) ');
disp('95% confidence interval for the mean:');
CI_c
disp(' (d) ');
disp('Check hypothesis that 52kV is the mean:');
H_d
P_d

%% (e)
close all;
clc;
clear;
sample = [41 46 47 47 48 50 50 50 50 50 50 50 48 50 50 50 50 50 50 50 52 52 53 55 50 50 50 50 52 52 53 53 53 53 53 57 52 52 53 53 53 53 53 53 54 54 55 68];
[H_e,P_e] = chi2gof(sample);
disp(' (e) ');
H_e
P_e
disp('Actual mean:');
mean(sample)