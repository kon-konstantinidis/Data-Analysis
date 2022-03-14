% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email:konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;

% Import European countries' names
EuroCountries = importdata('./EuropeanCountries.xlsx');
EuroCountries = EuroCountries.textdata;
EuroCountries = EuroCountries(:,2);

% Import Euro Countries' testing data
data = importdata('./ECDC-7Days-Testing.xlsx');
numData = data.data;
textData = data.textdata(2:end,:);
clear data;

% Select a week of 2020 - 2021, out of W45-W50, where positivity_rate{Iceland}=max
maxPR2020 = 0;
maxWeek2020=0;
maxPR2021 = 0;
maxWeek2021=0;
for i=1:size(textData,1)
    % Search in 2020
    if (strcmp(textData{i,1},'Iceland')&& strcmp(textData{i,3} ,'2020-W45'))
        % We've arrived at country A, week 45 of 2020, begin searching
        for j= i:(i+5)
            % If the country of this entry is not A (Iceland, as it should be) or
            % the year-week combo is not at least 2020-W44, then there are
            % mising entries or the data is misaligned
            if (~strcmp(textData{j,1},'Iceland') || sum(textData{j,3}>'2020-W44')~=1)
                disp('Error, data probably misaligned.');
            end
            % Check if this PR rate is higher
            if (numData(j,5) > maxPR2020)
                % If yes, update the corresponding variables
                maxPR2020 = numData(j,5);
                maxWeek2020 = textData{j,3};
            end
        end
    end
    % Search in 2021
    if (strcmp(textData{i,1},'Iceland')&& strcmp(textData{i,3} ,'2021-W45'))
        % We've arrived at country A,week 45 of 2021, begin searching
        for j=i:(i+5)
            if (~strcmp(textData{j,1},'Iceland') || isempty(textData{j,3}>'2021-W44'))
                disp('Error, data probably misaligned.');
            end
            if (numData(j,5) > maxPR2021)
                maxPR2021 = numData(j,5);
                maxWeek2021 = textData{j,3};
            end
        end
        break;
    end
end

% Get PRs for all European countries for weeks maxWeek2020 and maxWeek2021
PRweek2020 = {};
PRweek2021 = {};
for i=1:size(numData,1)
    % Not all countries in textData are European
    if (sum(cell2mat(strfind(EuroCountries,textData{i,1}))) == 1)
        % We are now in a European country
        
        % Find the right week and add the country, if we havent already
        % (since some countries have double entries for some dates, by
        % different sources)
        if (strcmp(textData{i,3},maxWeek2020) && strcmp(textData{i,4},'national') )
            if(size(PRweek2020,1)>0 && sum(cell2mat(strfind(PRweek2020(:,1),textData{i,1}))) == 0)
                PRweek2020{end+1,1} = textData{i,1}; % Store country name
                PRweek2020{end,2} = numData(i,5); % store positivity_rate
            % If the cell is empty, no need to check if the country has already
            % been added
            elseif (size(PRweek2020,1)==0)
                PRweek2020{end+1,1} = textData{i,1}; % Store country name
                PRweek2020{end,2} = numData(i,5); % store positivity_rate
            end
        end
        if (strcmp(textData{i,3},maxWeek2021)&& strcmp(textData{i,4},'national') )
            if (size(PRweek2021,1)>0 && sum(cell2mat(strfind(PRweek2021(:,1),textData{i,1}))) == 0)
                PRweek2021{end+1,1} = textData{i,1}; % Store country name
                PRweek2021{end,2} = numData(i,5); % store positivity_rate
            elseif (size(PRweek2021,1)==0)
                PRweek2021{end+1,1} = textData{i,1}; % Store country name
                PRweek2021{end,2} = numData(i,5); % store positivity_rate
            end
        end
    end
end
% PRweek2020 has 23 countries, not 25, because data is not full


%%% Make histograms

%%%%% 2020
figure(1);
% Get a preview of the data before fitting a distribution to it
histogram(cell2mat(PRweek2020(:,2)));

% Distribution of Positivity Rates for countries in 2021 could be viewed as
% a half normal distribution (seen better when nbins=5 on the histogram). 
% Nevertheless, the samples are extremely few to be able to accurately 
% determine the distribution they belong to.
dist2020 = fitdist(cell2mat(PRweek2020(:,2)),'Half Normal');
histfit(cell2mat(PRweek2020(:,2)),5,'half normal');
title(strcat('Positivity rates for: ',maxWeek2020));
xlabel('Positivity rate');
ylabel('Frequency');


%%%%% 2021
figure(2);
% Again, get a first look at the data before fitting a distribution to it
hist2info = histogram(cell2mat(PRweek2021(:,2)));

% Distribution of Positivity Rates for countries in 2021 could be viewed as
% a normal distribution (seen better when nbins=10 on the histogram). 
% Nevertheless, the samples are extremely few to be able to accurately 
% determine the distribution they belong to.
histfit(cell2mat(PRweek2021(:,2)),10,'normal');
title(strcat('Positivity rates for: ',maxWeek2021));
xlabel('Positivity rate');
ylabel('Frequency');

%%% Comments:
% At first glance, the PR values of 2020 and of 2021 are not easily
% described by the same distribution (the best distribution fit by eye differs)

% In the next exercise, that will be looked into in greater detail and a
% far more absolute answer will be given

% Save values for next exercise
save('./PRs.mat','PRweek2020','PRweek2021');