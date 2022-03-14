% Konstantinos Konstantinidis
% email:konkonstantinidis@ece.auth.gr
%
%
%Group77Exe3Fun2 Given a 7-day positivity rate for greece (PRs_Greek) and an average
% weekly positivity rate for the European Union (PR_EU), this function
% calculates the 95% Confidence Interval for that weeks positivity rate and
% returns the statisticall difference between that and PR_EU (if it
% exists), as well as the CI itself.
function [diff,CI_PR_Greece] = Group77Exe3Fun2(PRs_Greek, PR_EU)
diff = NaN;
% Get the confidence interval (CI) of the mean of the daily positivity rate
% (PR) of Greece, at a 5% significance level
CI_PR_Greece = bootci(50000,@mean,PRs_Greek);

% Check whether the PR of the European Union is included in that CI
if (CI_PR_Greece(1)>PR_EU)
    diff = PR_EU - CI_PR_Greece(1);
elseif (PR_EU>CI_PR_Greece(2))
    diff = PR_EU - CI_PR_Greece(2);
else
    disp(['European Union average weekly positivity rate is not '...
        'statistically significantly different than that of Greece']);
end
end