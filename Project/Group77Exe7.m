% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email:konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;

countryA = 'Ireland'; % see comments section at the end

%%%%% Data Importing - Extraction
% Import Euro Countries' data
EuroData = readtable('./ECDC-7Days-Testing.xlsx');
% Import Iceland's (country A) data
dataIndex = find(strcmp(countryA,EuroData{:,1}) & strcmp('national',EuroData{:,4}));
data = EuroData(dataIndex,{'year_week','positivity_rate'});

% Import data from
% https://github.com/owid/covid-19-data/tree/master/public/data/ in order
% to extract deaths for Iceland, see comments
owidData = readtable('./owid-covid-data.csv');
owidIndex = find(strcmp(countryA,owidData{:,3}));
deaths = owidData(owidIndex,[4 15]);
% Delete NaN entries (starting entries only have NaN values)
deaths(isnan(deaths{:,2}),:) = [];
% Convert date to year_week format
dates = cell(size(deaths,1),1);
for i=1:size(deaths,1)
    date = deaths{i,1};
    weekOfDate = week(date);
    yearOfDate = year(date);
    yearWeek = [num2str(yearOfDate),'-W',num2str(weekOfDate)];
    dates{i} = yearWeek;
end
deaths = table(dates,deaths{:,2});
deaths.Properties.VariableNames = {'year_week','deaths_per_million'};
% Convert daily dead to weekly dead (morbid, I know)
deathsYearWeek = cell2table(cell(ceil(size(deaths,1)/7) + 1,2),'VariableNames',{'year_week','deaths'});
deathsWriteIndex = 1;
% First, find out if when the first full week of data starts
fullWeekStartIndex = 1;
for i = 1 : 7
    if ( ~strcmp(deaths{i,1},deaths{1,1}) )
        fullWeekStartIndex = i;
        break;
    end
end
for i=5:7:size(deaths,1)
    weekDeaths = deaths{i,2};
    year_week = deaths{i,1};
    for j=(i+1):(i+6)
        if (j<size(deaths,1) && strcmp(deaths{j,1},year_week))
            weekDeaths = weekDeaths + deaths{j,2};
        end
    end
    deathsYearWeek(deathsWriteIndex,1) = year_week;
    deathsYearWeek.deaths{deathsWriteIndex} = weekDeaths;
    deathsWriteIndex = deathsWriteIndex + 1;
end
% Delete empty rows from table
for i=size(deathsYearWeek,1):-1:1
    if (isempty(deathsYearWeek.year_week{i}))
        deathsYearWeek(i,:) = [];
    end
end
mergeIndex = [];
searchIndex = 0;
while(isempty(mergeIndex))
    searchIndex = searchIndex + 1;
    mergeIndex = find(strcmp(data{searchIndex,1},deathsYearWeek{:,1}));
end
data(1:searchIndex-1,:) = []; % erase rows with no responding deaths value
% Merge two tables into one
data.deaths_per_million = NaN*ones(size(data,1),1);
for i=1:size(data,1)
    data.deaths_per_million(i) = deathsYearWeek.deaths{mergeIndex};
    mergeIndex = mergeIndex + 1;
end
% Workspace Cleanup
clear dataIndex date dates deaths deathsWriteIndex deathsYearWeek i j mergeIndex owidIndex searchIndex weekDeaths
clear weekOfDate year_week yearOfDate yearWeek
%%%%% Data imported-extracted


% data variable is now a table with 3 columns, year_week, PR and deaths
% Firstly, let's have a scatter plot of the data for the full timespan
figure('Position', [400 125 725 525]);
scatter(data.positivity_rate,data.deaths_per_million);
title(['Scatter plot for positivity rate - deaths per million from ',data.year_week{1},' to ',data.year_week{end}]);
xlabel('Positivity Rate');
ylabel('Deaths Per Million');
xDim = xlim;
yDim = ylim;
text(0.99*xDim(2),0.99*yDim(2),countryA,'HorizontalAlignment','right','VerticalAlignment','top');

% Fit a simple regression model to two different time periods of 16 weeks
% First period is from 2020-W18 to 2020-W32
% Second period is from 2020-W42 to 2021-W04
periods = {7:21,30:45};
figure('Position', [0 40 1600 750]);
Rsqrd = NaN*ones(2,6);
for w=0:5
    if (w==3)
        figure('Position', [0 40 1600 750]); % go to new figure
    end
    for p=1:2
        x=data.positivity_rate(periods{p} - w);
        y=data.deaths_per_million(periods{p});
        X = [ones(length(x),1) x];
        b = X\y;
        yfit = X*b;
        e = y - yfit;
        SSresid = sum(e.^2);
        n = length(x);
        SStotal = (n-1)*var(y);
        Rsquared = 1 - SSresid/SStotal;
        subplot(2,3,3*(p-1)+mod(w,3)+1),scatter(x,y);
        hold on ;
        plot(x,yfit,'r');
        title(['Simple Regression Model with lookback of ',num2str(w),' weeks']);
        xlabel('Positivity Rate');
        ylabel('Deaths Per Million');
        legend('Data','Regression Line','Location','best');
        xDim = xlim;
        yDim = ylim;
        text(xDim(1)+xDim(2)/20,yDim(2),['R^2: ',num2str(Rsquared)],'HorizontalAlignment','left','VerticalAlignment','top');
        % Save R-squared metric to determine the best models later
        Rsqrd(p,w+1) = Rsquared;
    end
end

% Compute what the best week lag/lookback number was
[period1BestRsqrd,period1BestIndex] = max(Rsqrd(1,:));
fprintf('The model that predicted best for the first period (%s - %s, R-squared=%1.3f) had a lag of %d weeks.\n',...
    data.year_week{periods{1}(1)},data.year_week{periods{1}(end)},period1BestRsqrd,period1BestIndex-1);
[period2BestRsqrd,period2BestIndex] = max(Rsqrd(2,:));
fprintf('The model that predicted best for the second period (%s - %s, R-squared=%2.3f) had a lag of %d weeks.\n',...
    data.year_week{periods{2}(1)},data.year_week{periods{2}(end)},period2BestRsqrd,period2BestIndex-1);

%%% Comments:

% Country A had only 12% non-zero weakly dead values (good for them, bad
% for fitting and visualizing a linear model), so instead a transition was
% made to its alphabetic neighboor Ireland (93% non-zero weekly dead values).

% Covid deaths data was extracted from the source cited at the page:
% https://www.stelios67pi.eu/testing.html, in order to avoid copy-pasting
% raw data. As a result, the program now works for all countries that
% have records in both ECDC-7Days-Testing.xlsx and owid-covid-data.csv.
