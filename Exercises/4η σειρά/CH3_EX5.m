% Chapter 3 - Exercise 5
clc;
clear;
close all;
eruption = importdata("eruption.dat").data; % import dataset

%% (a)
% Get 95% CI for sigmas of 1989 waiting time and eruption duration and 2006 waiting time
CIs_sigma = [];
for i=1:3
    data = eruption(:,i);
    pd = fitdist(data,'Normal');
    res = paramci(pd);
    CIs_sigma(i,:) = res(:,2); % second col of res has the CI for sigma
end
disp("   (a)   ");
disp("CI of sigma of 1989 waiting time:");
CIs_sigma(1,:)
disp("CI of sigma of 1989 eruption duration:");
CIs_sigma(2,:)
disp("CI of sigma of whatever the 2006 records are supposed to be:");
CIs_sigma(3,:)
%% (b)
% Get 95% CI for mean of 1989 waiting time and eruption duration and 2006 waiting time
CIs_mean = [];
for i=1:3
    data = eruption(:,i);
    pd = fitdist(data,'Normal');
    res = paramci(pd);
    CIs_mean(i,:) = res(:,1); % second col of res has the CI for sigma
end
disp("   (b)   ");
disp("CI of mean of 1989 waiting time:");
CIs_mean(1,:)
disp("CI of mean of 1989 eruption duration:");
CIs_mean(2,:)
disp("CI of mean of whatever the 2006 records are supposed to be:");
CIs_mean(3,:)
%% (c)
disp("   (c)   ");
for i=1:3
[H,P] = chi2gof(eruption(:,i))
end
%% Wikipedia claim 1
claim1Indexes = find(eruption(:,2) < 2.5); % get indexes of eruption duration > 2.5
claim1Data = eruption(claim1Indexes,1); % get values of waiting times at those indexes
pd = fitdist(claim1Data,'Normal');
res1 = paramci(pd);
disp("Mean time of waiting after an eruption of duration<2.5:");
res1(:,1)
disp("Standard variance of that:");
res1(:,2)

%% Wikipedia claim 2
claim2Indexes = find(eruption(:,2) > 2.5); % get indexes of eruption duration > 2.5
claim2Data = eruption(claim2Indexes,1); % get values of waiting times at those indexes
pd = fitdist(claim2Data,'Normal');
res2 = paramci(pd);
disp("Mean time of waiting after an eruption of duration>2.5:");
res2(:,1)
disp("Standard variance of that:");
res2(:,2)