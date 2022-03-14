% Chapter 4 - Exercise 2
clc;
close all;
clear;

%% (a)
og_std = 5;
X = 500;
Y = 300;
res_std = sqrt((X+Y)^2*og_std^2);
% res_std=constant when (X+Y)^2 = constant => X+Y=constant

%% (b)
n = 1000;
X2 = 1:1:n;
Y2 = 1:1:n;
height = zeros(n,n);
for i = 1:n
    for j = 1:n
        height(i,j) = sqrt( X2(i)^2*res_std^2 + Y2(j)^2*res_std^2 );
    end
end
% Surface
h = surf(X2,Y2,height);
set(h,'LineStyle','none');