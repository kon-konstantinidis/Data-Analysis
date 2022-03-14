% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email: konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;

load('./PRs.mat');
% The samples have already been plotted in the previous exercise
bootstrapReps = 100000;
n=size(PRweek2020,1);
m=size(PRweek2021,1);
XY = [cell2mat(PRweek2020(:,2));cell2mat(PRweek2021(:,2))];
bootstrapResults = NaN*ones(1,bootstrapReps);
bootstrapResults2 = NaN*ones(1,bootstrapReps);
for rep=1:bootstrapReps
    % Generate two boostrap samples of XY
    bootstrap_samples = randsample(XY,m+n,true);
    x_sample = bootstrap_samples(1:n);
    y_sample = bootstrap_samples(n+1:n+m);
    
    % For the two boostrap samples generated, calculate the statistic
    [~,~,stat] = kstest2(x_sample,y_sample);
    % And store it
    bootstrapResults(rep) = stat;
end
% Sort the statistic's scores
bootstrapResults = sort(bootstrapResults);

% Two-sample Kolmogorov-Smirnov test for the original samples
[H_ktest2,P,stat] = kstest2(cell2mat(PRweek2020(:,2)),cell2mat(PRweek2021(:,2)));

% Now, let's find out how extreme that P value actually is
[~,pos] = min(abs(bootstrapResults-P));
alpha = 0.05; % default 5% significance level

if(pos < ( (bootstrapReps+1)*alpha )/2 || pos>(bootstrapReps+1)*(1-alpha/2))
    H_manual = 1; %reject null hypothesis, samples belong to different distributions
else
    H_manual = 0; %accept null hypothesis, samples come from the same distribution
end

% Print message for the result
if (H_manual == 0)
    disp('PRweek2020 and PRweek2021 belong to the same distribution');
else
    disp('PRweek2020 and PRweek2021 DO NOT belong to the same distribution');
end

%%% Comments: NONE

