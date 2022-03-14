% Chapter 2 - Exercise 6 (Second set)
clear all;
clc;

% Parameter initialization
n = 100; % # of random variables
N = 10000; % # of values of n variables

means = zeros(1,n);
for i = 1:n
    rands = unifrnd(1,2,1,N);
    means(i) = mean(rands);
end

% Plots
figure();
hold on;
title("Histogram of uniform mean values and plot of fitted normal distribution");
xlabel("Mean value");
ylabel("Frequency");
histogram(means);
% plot normal distribution on top
fittedNorm = fitdist(means','Normal');
normY = normpdf(linspace(1,2),fittedNorm.mu, fittedNorm.sigma);
plot(linspace(1,2),normY);
axis([1.45, 1.55 0 40]);