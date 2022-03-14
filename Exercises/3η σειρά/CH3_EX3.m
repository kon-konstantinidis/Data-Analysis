% Chapter 3 - Exercise 3

%% (a)
close all;
clc;
clear;
M = 1000;
n = 5;
mu = 1/15;
values = exprnd(mu,M,n);
percACounter=0;
for i=1:M
    [~,~,CI] = ttest(values(i,:),mu);
    if (CI(1)<=mu && mu<=CI(2))
        percACounter = percACounter + 1;
    end
end
percACounter = percACounter/M;
disp(' (a) ');
disp('Percentage that the mean lifespan is in the 95% confidence interval');
percentages_A = percACounter

%% (b)
close all;
clear;
M = 1000;
n = 100;
mu = 1/15;
values = exprnd(mu,M,n);
percBCounter = 0;
for i=1:M
    [~,~,CI] = ttest(values(i,:),mu);
    if (CI(1)<=mu && mu<=CI(2))
        percBCounter = percBCounter + 1;
    end
end
percBCounter = percBCounter/M;
disp(' (b) ');
disp('Percentage that the mean lifespan is in the 95% confidence interval');
percentages_B = percBCounter

%% Plots the mean of percentages for different values of n
close all;
clc;
clear;
M = 1000;
maxReps = 10;
n = 2.^[1:1:maxReps];
mu = 1/15;
meanPercentages = zeros(1,maxReps);
percCounterN = zeros(1,maxReps);
for reps = 1:maxReps
    values = exprnd(mu,M,n(reps));
    for i=1:M
        [~,~,CI] = ttest(values(i,:),mu);
        if (CI(1)<=mu && mu<=CI(2))
        percCounterN(reps) = percCounterN(reps) + 1;
        end
    end
    percCounterN(reps) = percCounterN(reps)/M;
end
figure();
plot(log2(n),percCounterN);
title('Mean percentage as f(n)');

%% Plots the mean of percentages for different values of M
close all;
clc;
clear;
maxReps = 10;
M = 2.^[1:1:maxReps];
n = 25;
mu = 1/15;
meanPercentages = zeros(1,maxReps);
percCounterM = zeros(1,maxReps);
for reps = 1:maxReps
    values = exprnd(mu,M(reps),n);
    for i=1:M(reps)
        [~,~,CI] = ttest(values(i,:),mu);
        if (CI(1)<=mu && mu<=CI(2))
        percCounterM(reps) = percCounterM(reps) + 1;
        end
    end
    percCounterM(reps) = percCounterM(reps)/M(reps);
end
figure();
plot(log2(M),percCounterM);
title('Mean percentage as f(M)');