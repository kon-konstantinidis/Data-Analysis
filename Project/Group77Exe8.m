% Konstantinos Konstantinidis
% AEM: 9162 ||| Country A:(mod(9162,25)+1 = 13 - Iceland)
% email:konkonstantinidis@ece.auth.gr
clear all;
clc;
close all;


%%%%% Data Importing - Extraction
% Import EODY data and make a table for daily PR of Greece
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
Greece = table(EODY.Date,PR,EODY.New_Deaths);
Greece.Properties.VariableNames = {'Date','PR','Deaths'};

% Throw away a subset of data with NaN deaths, we need continues clean data
nansIndexes = find(isnan(Greece.Deaths) == 1);
Greece = Greece(max(nansIndexes)+1:end,:);
% Workspace Cleanup
clear i nansIndexes PCRs PR Rapids
%%%%% Data imported-extracted
% Select two different 12 week periods (84 days each)

periods = {32:115, 230:313};
adj_R2 = NaN*ones(2,30);
for daysPast = 1 : 30
    for p=1:2
        y = Greece.Deaths(periods{p});
        n=length(y);
        % Make feature matrix
        X = NaN*ones(n,daysPast);
        for i=1:(daysPast)
            X(:,i) = Greece.PR(periods{p} - i);
        end
        XX = [ones(n,1) X]; % column of ones should be included
        [b,bCI,residuals,residualsInt,~] = regress(y,XX);
        yfit = XX*b;
        e = y - yfit;
        SSresid = sum(e.^2);
        SStotal = (n-1) * var(y);
        Rsqrd = 1 - SSresid/SStotal;
        adjRsqrd = 1 - SSresid/SStotal * (n-1)/(n-length(b)-1);
        adj_R2(p,daysPast) = adjRsqrd;
    end
end
% Find out which model (with how many days of lookback data) performed
% better
[period1BestAdjRsqrd,period1BestIndex] = max(adj_R2(1,:));
fprintf(['The model that predicted best for the first period (%s to %s, adjusted R-squared=%1.4f) had data\nof up'...
    ' to %d weeks back.\n\n'], Greece.Date(periods{1}(1)),Greece.Date(periods{1}(end)),period1BestAdjRsqrd,...
    period1BestIndex);
[period2BestAdjRsqrd,period2BestIndex] = max(adj_R2(2,:));
fprintf(['The model that predicted best for the second period (%s to %s, adjusted R-squared=%1.4f) had data\nof up'...
    ' to %d weeks back.\n\n'], Greece.Date(periods{2}(1)),Greece.Date(periods{2}(end)),period2BestAdjRsqrd,...
    period2BestIndex);


% Dimensionality Reduction using stepwise regression
% Firstly, build the full models of 30 variables to have for comparisons
% for both periods
daysPast = 30;
for p=1:2
    y = Greece.Deaths(periods{p});
    n=length(y);
    % Make feature matrix
    X = NaN*ones(n,daysPast);
    for i=1:(daysPast)
        X(:,i) = Greece.PR(periods{p} - i);
    end
    XX = [ones(n,1) X]; % column of ones should be included for regress function
    [bFull,bCI,residuals,~,~] = regress(y,XX);
    yfitFull = XX*bFull;
    eFull = y - yfitFull;
    SSresidFull = sum(eFull.^2);
    SStotalFull = (n-1) * var(y);
    RsqrdFull = 1 - SSresidFull/SStotalFull;
    adjRsqrdFull = 1 - SSresidFull/SStotalFull * (n-1)/(n-length(bFull)-1);
    
    % Now, employ a stepwise regression using the same data
    [bReduced,se,pval,inmodel,stats,nextstep,history]=stepwisefit(X,y,'Display','off');
    b0 = stats.intercept;
    for i=1:length(bReduced)
        if (inmodel(i) == 0)
            bReduced(i) = 0;
        end
    end
    bReduced = [b0; bReduced];
    yfitReduced = [ones(n,1) X]*bReduced;
    eReduced = y - yfitReduced;
    SSresidReduced = sum(eReduced.^2);
    SStotalReduced = (n-1) * var(y);
    RsqReduced = 1 - SSresidReduced/SStotalReduced;
    adjRsqReduced = 1 - SSresidReduced/SStotalReduced * (n-1)/(n-length(bReduced)-1);
    
    % Compare the full model to the reduced model, for this time period
   disp(['Period ',num2str(p),': ',datestr(Greece.Date(periods{p}(1))),' to ',datestr(Greece.Date(periods{p}(end)))]);
   fprintf('Full model of 30 variables has adjusted R-squared=%1.4f\n',adjRsqrdFull);
   fprintf('Reduced model of %d variables has adjusted R-squared=%1.4f\n',sum(inmodel),adjRsqReduced);
   if (adjRsqReduced>=adjRsqrdFull)
       disp('Reduced model performs better for this period.');
   else
       disp('Full model performs better for this period.');
   end
   disp(' ');
end

%%% Comments: 
% The printed messages display both the models' performance as well as the
% number of variables they employ. The coefficients are not printed to
% avoid a big list of numbers, they can however be accessed via the workspace.

% The comparison of the models perfomance is strict, so if a model performs
% even slightly better, that model is chosen as the best performer. There
% is however something to be said about a reduced model that can perform
% almost just as well as the full model, while using 1/3 of the variables
% (i.e. the data volume) of the full model (faster, more portable, etc.).


% Thank you.