% Konstantinos Konstantinidis
% email:konkonstantinidis@ece.auth.gr
%
%Group77Exe3Fun1   Given a valid year and week in (YYYY-WXX) format (e.g. 2020-W14), 
% this function will extract and compute the average positivity rate for the 
% countries in CountryNames, in the year_week timespan, extracting the data 
% from dataTable.
%
% PR = Group77Exe3Fun1(year_week, dataTable, CountryNames)  finds the average
% positivity rate (PR) for the year-week combination year_week, in the
% provided dataTable, for countries whose names are in cell array
% CountryNames. dataTable must have the country name in the 1st column, the
% year_week entries in the 3rd column and  the area of the applied
% sampling ('nationa', 'subnation', etc) in the 4th column.
% 
% NOTE: It is meant to be used for European Countries, but it can just as
% well be applied to any one country or combination thereof.
function [PR] = Group77Exe3Fun1(year_week, dataTable, CountryNames)
PR = 0;
divFactor = length(CountryNames) - 1; %factor to divide the sum of PRs with
for i=1:length(CountryNames)
    if (strcmp(CountryNames{i},'Country'))
        continue;
    end
    index = find(strcmp(CountryNames{i},dataTable{:,1}) & strcmp('national',dataTable{:,4}) & strcmp(year_week,dataTable{:,3}));
    % Depending on the index, three cases can be discerned
    if (size(index,1)==1) % we found exactly one record, great
        PR = PR + dataTable{index,11};
    elseif (size(index,1)>1) % multiple records, not great
        disp('Warning, multiple possible records fit search');
    elseif (size(index,1)==0) % no records, happens, just notify the user
        disp(strcat(['Country ',CountryNames{i},' has no records for date ',year_week,'.']));
        divFactor = divFactor - 1; % this country is then not included in the mean PR
    end
end
PR = PR/divFactor;
end