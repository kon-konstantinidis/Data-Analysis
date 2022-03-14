% Chapter 2 - Exercise 4 (Second set)

% Bounds
lowerBound = 1;
upperBound = 2;
% Initialize the reps vector
step = 1:1:25; % 
reps = 2.^step;

% Initialize the E[1/X] and 1/E[X] vectors respectively
invX_E = zeros(length(step),1);
invE = zeros(length(step),1);


% Run the simulation for all repetition ranges
for i=1:length(reps)
    fprintf("Repetion: %d \n", i);
    % Returns vector of uniformly distributed values in [1,2]
    randNum = unifrnd(lowerBound,upperBound,1,reps(i));
    invE(i) = 1/mean(randNum);
    invX_E(i) = mean(1./randNum);
end

% Plot
figure();
title("E[1/X](RED) relative to 1/E[X](GREEN)");
ylabel("Mean value");
xlabel("Sample size");
hold on;
plot(log2(reps),invX_E,'red');
plot(log2(reps),invE,'green');