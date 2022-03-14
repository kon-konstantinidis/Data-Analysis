% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email:konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;

plotData = true;
alphas = [0.05, 0.01];
randReps = 100000;

%%%%% Data Importing - Extraction
% Import European countries' names
EuroCountries = importdata('./EuropeanCountries.xlsx');
EuroCountries = EuroCountries.textdata;
EuroCountries = EuroCountries(2:end,2);
% Import Euro Countries' data
EuroData = readtable('./ECDC-7Days-Testing.xlsx');

%Import EODY data and make a table for daily PR of Greece
% Import EODY data - select features
EODY = readtable('./FullEodyData.xlsx');
% Remove last 7 empty rows
EODY(end-6:end,:) = [];
% Get PCR tests and Rapid tests
PCRs = EODY.PCR_Tests;
Rapids = EODY.Rapid_Tests;
% Replace NaN test numbers with 0, else PR calculations return NaN
PCRs(isnan(PCRs))=0;
Rapids(isnan(Rapids))=0;
% PCRs and Rapids are cumulative, that must change to compute the PR
for i=length(PCRs):-1:2
    PCRs(i) = PCRs(i)-PCRs(i-1);
    Rapids(i) = Rapids(i)-Rapids(i-1);
end
% Compute daily positivity rate(PR) % for Greece
PR = 100.*((EODY.NewCases)./(PCRs + Rapids));
Greece = table(EODY.Date,PR);
Greece.Properties.VariableNames = {'Date','PR'};

% Compute the weekly PR for weeks W38-W50 of 2021 for Greece
Greece_PRs = NaN*ones(1,13);
for w=0:12
    weekNumber = 38+w;
    % Find Greece's 7-day PRs for that week
    GRindexes = find(weekNumber==week(Greece{:,1}) & 2021 == Greece{:,1}.Year);
    GreeceDailyPRs = Greece{GRindexes,2};
    Greece_PRs(w+1) = mean(GreeceDailyPRs);
end
%%%%% Data imported-extracted

% Get the 4 countries that are alphabetic neighbors of country A: Iceland
icelandIndex = find(strcmp('Iceland',EuroCountries));
iceland5 = EuroCountries(icelandIndex-2:icelandIndex+2);

% For each country in those 5, make the requested comparisons
figure('Position', [300 125 1000 650]); % set figure size, CHANGE if host computer has smaller window size
for i=1:length(iceland5)
    % Find indexes for the start of W38 of 2020 for country i
    data2021StartIndex = find(strcmp(iceland5{i},EuroData{:,1}) & strcmp('national',EuroData{:,4})...
        & strcmp('2021-W38',EuroData{:,3}));
    data2021 = zeros(1,13);
    % Copy the data to vectors
    for j=0:12
        data2021(j+1) = EuroData{data2021StartIndex+j,11};
    end
    % Scatter plot Greece PRs country i's PRs (if plotData=true)
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
        subplot(3, 4, [x y]),scatter(Greece_PRs,data2021,'red');
        title(['Scatter plot of Positivity Rates for Greece and ',iceland5{i}]);
        xlabel('Greece''s PRs');
        ylabel([iceland5{i},'''s PRs']);
    end
    % Compute Pearson correlation distribution via bootstraping
    randRes = NaN*ones(randReps,1);
    n=13;
    r = corr(Greece_PRs',data2021');
    t0 = r*sqrt((n-2)/(1-r^2));
    for rep=1:randReps
        randSampleGreece = randsample(Greece_PRs,n,false);
        rr = corr(randSampleGreece',data2021');
        randRes(rep) = rr*sqrt((n-2)*(1-rr^2));
    end
    randRes = sort(randRes);

    [~,pos] = min(abs(randRes-t0));
    % Calculate pval of the correlation of the original data
    pval = NaN;
    if (pos<= length(randRes)/2 )
        pval = ((2*pos)/(randReps+1));
    else
        newPos = length(randRes) - pos;
        pval = ((2*newPos)/(randReps+1));
    end
    disp([iceland5{i},' - Greece : ']);
    fprintf('Correlation is %f.\n',r);
    disp('Randomization result:');
    for a = 1:length(alphas)
        if(pos < ( randReps*alphas(a) )/2 || pos>randReps*(1-alphas(a)/2))
            disp(['Correlation is statistically significant at the ',num2str(alphas(a)),' importance level.']);
        else
            disp(['Correlation is NOT statistically significant at the ',num2str(alphas(a)),' importance level.']);
        end
    end
    
    % Parametric testing for correlation r
    disp('Parametric result:');
    % First, transform r to z according to Fisher
    z = 0.5*log((1+r)./(1-r));
    for a=1:2
        z_low = z-(norminv(1-alphas(a)/2)*sqrt(1/(n-3)));
        z_upper = z+(norminv(1-alphas(a)/2)*sqrt(1/(n-3)));
        r_low = tanh(z_low);
        r_upper = tanh(z_upper);
        disp(['Confidence Interval of correlation r is [',num2str(r_low),',',num2str(r_upper),']'...
            ' at ',num2str(alphas(a)),' importance level.']);
        if (r_low <=0 && r_upper>=0)
            disp('Confidence Interval of correlation includes 0, cannnot conclude that there is a correlation.');
        else
            disp('Confidence Interval of correlation does NOT includes 0, we CAN conclude that there is a correlation.');
        end
    end
    disp(' ');
end

%%% Comments:
% As the results show (randomization and parametric tests alike), we can
% conclude that there is a correlation between the positivity rates of
% Greece and Germany/Hungary/Iceland/Ireland, while we cannot conclude that
% there is a correlation at either importance level (0.05/0.01) for Greece
% and Italy via the parametric test, in constrast to the randomization test.
% In addition, the correlation of most statististical importance
% (there are many that are statistically important however) is that of
% Greece and Hungary, featuring a correlation of ~0.89, that's a rarer
% value.