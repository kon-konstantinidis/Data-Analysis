% Chapter 5 - Exercise 4
clc;
close all;
clear;

lightair = importdata("lightair.dat");
airDensity = lightair(:,1);
c = lightair(:,2);
coef = corrcoef(airDensity,c);
%% (a)
figure();
scatter(airDensity, c);
hold on;
title("Scatter plot");
xlabel("Air density");
ylabel("Speed Of Light");

%% (b)
model = fitlm(airDensity,c);
modelCoefs = model.Coefficients.Estimate;

% Plot regression atributes
airDensityOnes = [ones(length(airDensity),1) airDensity];
regression = airDensityOnes*modelCoefs;
plot(airDensity,regression,'-')
hold on;

regCoefs_CI = coefCI(model);

%% (c)
% Plot CIs
[~,ypredCI] = predict(model, airDensity, 'Prediction', 'curve');
[~,yobservCI] = predict(model, airDensity, 'Prediction', 'observation');
plot(airDensity,ypredCI,'--')
hold on;
plot(airDensity,yobservCI,'-.')
hold on;

% Predicting for air density = 1.29
airDens0 = 1.29;
[ypred,ypredCI] = predict(model, airDens0, 'Prediction', 'curve');
[~,yobservCI] = predict(model, airDens0, 'Prediction', 'observation');
plot(airDens0 , ypred,'x');
plot(airDens0, ypredCI,'*');
plot(airDens0, yobservCI,'p');
