% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email:konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;


%%%%% Import European data
% Import European countries' names
EuroCountries = importdata('./EuropeanCountries.xlsx');
EuroCountries = EuroCountries.textdata;
EuroCountries = EuroCountries(:,2);
% Import Euro Countries' data
EuroData = readtable('./ECDC-7Days-Testing.xlsx');

%%%%% Import EODY data and make a table for daily PR of Greece
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

% Find out when Iceland (Country A) peaks for the last time
icelandIndexes = find(strcmp('Iceland',EuroData{:,1}) & strcmp('national',EuroData{:,4}));
icelandPRs = EuroData{icelandIndexes,11};
figure();
plot(icelandPRs);
title('Positivity Rate for Iceland');
xlabel('Weeks');
ylabel('Positivity Rate');

% Judging by eye, the last (clearly seen) peak for Iceland was during index 77, so:
% For 12 weeks, starting at AlastPeakWeek
diffs = zeros(1,12);
EU_PRs = zeros(1,12); % European weekly PRs for the 12 week timespan
Greece_PRs = zeros(1,12); % Greek weekly PRs for the 12 week timespan
GreekCIsLeft = zeros(1,12); % Confidence Intervals (left) for Greece's weekly PR
GreekCIsRight = zeros(1,12); % Confidence Intervals (right) for Greece's weekly PR
for w=0:11
    currWeek = EuroData{icelandIndexes(77-w),3};
    weekNumber = str2double(currWeek{1}(end-1:end));
    yearNumber = str2double(currWeek{1}(1:4));
    % Find this week's average Euro PR for all Euro countries
    EU_PRs(w+1) = Group77Exe3Fun1(currWeek,EuroData,EuroCountries);
    % Find Greece's 7-day PRs for that week
    GRindexes = find(weekNumber==week(Greece{:,1}) & yearNumber == Greece{:,1}.Year);
    GreeceDailyPRs = Greece{GRindexes,2};
    Greece_PRs(w+1) = mean(GreeceDailyPRs);
    [diffs(w+1),CI] = Group77Exe3Fun2(GreeceDailyPRs, EU_PRs(w+1));
    GreekCIsLeft(w+1) = CI(1);
    GreekCIsRight(w+1) = CI(2);
end

%%% Diagrams

% Plot of EU_PRs - Greece_PRs and the CI
figure();
plot(Greece_PRs,'color','green');
title('PRs over a 12-week timespan for Greece (green) and EU (blue)');
xlabel('Weeks');
ylabel('Positivity Rate');
hold on;
plot(EU_PRs,'color','blue');
% Also plot the left and right confidence interval
plot(GreekCIsLeft,'-.r');
plot(GreekCIsRight,'-.r');
legend('Greek PRs','EU PRs','Lower and Upper CI of Greek PRs');
xlim([1 12]);

% Histograms of EU_PRs - Greece_PRs, along with vertical CI lines
figure();
histogram(Greece_PRs,'FaceColor','green');
title('PRs over a 12-week timespan for Greece (green) and EU (blue)');
xlabel('Positivity Rate (PR)');
ylabel('Frequency');
hold on;
histogram(EU_PRs,'FaceColor','blue');
% Plot two red lines as the means of the left and right limits of the CI
xline(mean(GreekCIsLeft),'r:');
xline(mean(GreekCIsRight),'r:');
legend('Greek PRs','EU PRs','Left and Right CI of Greek PRs');
hold off;

% Plot of diffs
% Difference will be 0 if Euro PR is within 95% CI of avg Greece PR
figure();
diffs(isnan(diffs))=0;
plot(diffs,'lineWidth',3);
title('Signed SI difference of weekly Euro-Greece PR');
xlabel('Weeks');
ylabel('Statistically Important Difference');
legend('Line will default to 0 if Euro PR is in the 95% CI of Greece PR for that week','Location','best');
xlim([1 12]);

%%% Comments: 
% Figure 2 (Plot of EU_PRs - Greece_PRs and the CI) demonstrates the
% behavior of Greek/Euro PRs much better, the other figures are simply
% added as a compliment.