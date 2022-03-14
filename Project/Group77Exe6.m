% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email:konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;

alpha = 0.05;
bootstrapReps = 50000;

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

mostCorrCountries = {'Hungary','Ireland'};
Hungary_PRs = [];
Ireland_PRs = [];
for i=1:length(mostCorrCountries)
    % Find indexes for the start of W38 of 2020 for country i
    data2021StartIndex = find(strcmp(mostCorrCountries{i},EuroData{:,1}) & strcmp('national',EuroData{:,4})...
        & strcmp('2021-W38',EuroData{:,3}));
    data2021 = zeros(1,13);
    % Copy the data to vectors
    for j=0:12
        data2021(j+1) = EuroData{data2021StartIndex+j,11};
    end
    if (i==1)
        Hungary_PRs = data2021;
    else
        Ireland_PRs = data2021;
    end
end
% Some variable cleanup
clear data2021 data2021StartIndex i j weekNumber GreeceDailyPRs GRindexes PR PCRs Rapids w
%%%%% Data imported-extracted

%%% Perform bootstrap check
XY = [Greece_PRs',Hungary_PRs';Greece_PRs',Ireland_PRs'];
n = 13;
m = 13;
bootstrapRes = NaN*ones(1,bootstrapReps);
for k=1:bootstrapReps
    bootstrap_samples_indexes = randsample(m+n,m+n,true);
    bootstrap_samples = XY(bootstrap_samples_indexes,:);
    x1 = bootstrap_samples(1:n,1);
    x2 = bootstrap_samples(1:n,2);
    x_r = corr(x1,x2);
    y1 = bootstrap_samples((n+1:n+m),1);
    y2 = bootstrap_samples((n+1:n+m),2);
    y_r = corr(y1,y2);
    bootstrapRes(k) = x_r - y_r;
end
bootstrapRes = sort(bootstrapRes);
Greece_Hungary_corr = corr(Greece_PRs',Hungary_PRs');
Greece_Ireland_corr = corr(Greece_PRs',Ireland_PRs');
[~,pos] = min(abs(bootstrapRes-(Greece_Hungary_corr- Greece_Ireland_corr)));

disp('Bootstrap result:');
if(pos < ( (bootstrapReps+1)*alpha )/2 || pos>(bootstrapReps+1)*(1-alpha/2))
    H = 1; % reject null hypothesis
    fprintf('The two correlations statistically significantly different ');
else
    H = 0; % accept null hypothesis
    fprintf('The two correlations are NOT statistically significantly different ');
end
fprintf('at the %2.2f%% significance level.\n',100*alpha);
%%% Comments: NONE