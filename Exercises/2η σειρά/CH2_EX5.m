% Chapter 2 - Exercise 5 (Second set)
clear all;
clc;
% Creating the cumulative density function of X~N(4,0.01)
x = 3.5:0.01:4.5;
y = normcdf(x,4,0.1);
plot(x,y);

% Chance a rod is destroyed:
% rod length<3.9 => cdf(3.9)
disp('Chance a rod is destroyed');
y(find(x==3.9)) % 41th place corresponds to 3.9 rod length

% Requested rod destruction chance: max 1%
% => cdf(largestIndex) <= 0.01
y(18:22) % => y(20)
disp('New rod length lower limit:');
x(20)