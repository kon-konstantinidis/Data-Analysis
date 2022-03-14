% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email:konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;

plotData = true;
bootstrapReps = 10000;
alpha = 0.05;

%%%%% Import European data
% Import European countries' names
EuroCountries = importdata('./EuropeanCountries.xlsx');
EuroCountries = EuroCountries.textdata;
EuroCountries = EuroCountries(2:end,2);
% Import Euro Countries' data
EuroData = readtable('./ECDC-7Days-Testing.xlsx');

% Get the 4 countries that are alphabetic neighbors of country A: Iceland
icelandIndex = find(strcmp('Iceland',EuroCountries));
iceland5 = EuroCountries(icelandIndex-2:icelandIndex+2);

% For each country in those 5, make the requested comparisons
Hs_bootstrap = NaN*ones(1,length(iceland5));
Hs_ttest = NaN*ones(1,length(iceland5));
figure('Position', [300 125 1000 650]); % set figure size, CHANGE if host computer has smaller window size

for i=1:length(iceland5)
    % Find indexes for the start of W42 of 2020 and 2021
    data2020StartIndex = find(strcmp(iceland5{i},EuroData{:,1}) & strcmp('national',EuroData{:,4})...
        & strcmp('2020-W42',EuroData{:,3}));
    data2021StartIndex = find(strcmp(iceland5{i},EuroData{:,1}) & strcmp('national',EuroData{:,4})...
        & strcmp('2021-W42',EuroData{:,3}));
    data2020 = zeros(1,9);
    data2021 = zeros(1,9);
    
    % Copy the data to the respective vectors
    for j=0:8
        data2020(j+1) = EuroData{data2020StartIndex+j,11};
        data2021(j+1) = EuroData{data2021StartIndex+j,11};
    end
    
    % Plot data2020 and data2021 (if plotData=true)
    if (plotData)
        % Plot on the right part of the figure
        x=0;
        y=0;
        if(i<=2)
            x= 2*i-1;
            y = 2*i;
        elseif(i==3)
            x = 6;
            y = 7;
        elseif(i>3)
            x = 2*i + 1;
            y = 2*i + 2;
        end
        subplot(3, 4, [x y]),plot(data2020,'red');
        hold on;
        plot(data2021,'green');
        title(['Positivity Rates for ',iceland5{i}]);
        xlabel('Weeks 42-50');
        ylabel('Positivity Rate');
        legend('W42-W50 for 2020', 'W42-W50 for 2021','Location','best');
    end
    
    % Check if data2020 is statistically significantly different to
    % data2021
    XY = [data2020, data2021];
    n = 9;
    m = 9;
    bootstrapRes = NaN*ones(1,bootstrapReps);
    for k=1:bootstrapReps
        bootstrap_samples = randsample(XY,m+n,true);
        x_mean = mean(bootstrap_samples(1:n));
        y_mean = mean(bootstrap_samples(n+1:n+m));
        bootstrapRes(k) = x_mean - y_mean;
    end
    bootstrapRes = sort(bootstrapRes);
    [~,pos] = min(abs(bootstrapRes-(mean(data2020)- mean(data2021))));
    
    disp('Bootstrap result:');
    if(pos < ( (bootstrapReps+1)*alpha )/2 || pos>(bootstrapReps+1)*(1-alpha/2))
        H = 1; % reject null hypothesis
        disp([iceland5{i},' has a statistically significantly different PR between the last months',...
        ' of 2021 vs 2021']);
    else
        H = 0; % accept null hypothesis
        disp([iceland5{i},' does not have a statistically significantly different PR between the last months',...
        ' of 2021 vs 2021']);
    end
    Hs_bootstrap(i) = H;
    
    % Lastly, also perform the t-test
    H = ttest2(data2020,data2021);
    disp('t-test result:');
    if(H==1)
        disp([iceland5{i},' has a statistically significantly different PR between the last months',...
        ' of 2021 vs 2021']);
    else
        disp([iceland5{i},' does not have a statistically significantly different PR between the last months',...
        ' of 2021 vs 2021']);
    end
    Hs_ttest(i) = H;
    disp(' ');
end

%%% Comments: 
% As the results show, 4 out of the 5 countries, namely:
% (Germany,Iceland,Ireland,Italy) have statistically significant
% differences between the last two months of 2020 vs the last two months of
% 2021. On the other hand, Hungary does not.

% This is also noticeable in the diagram plots.