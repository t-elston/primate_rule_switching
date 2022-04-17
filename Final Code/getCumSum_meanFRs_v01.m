function [dummyMeanFR_byCS] = getCumSum_meanFRs_v01(cumSum_data,meanFRs,trialIDXs)

dummyMeanFR_byCS = NaN(1,10);

% extract the relevant data
usable_cumSum = cumSum_data(trialIDXs);
firingRates   = meanFRs(trialIDXs);

% how many values of cumSum are there?
cumSums = unique(usable_cumSum);

for cs_ix = 1:numel(cumSums)
this_cumSum = cumSums(cs_ix);

trialsWithThis_CS = usable_cumSum == this_cumSum;

% get the mean firing rates during those trials
dummyMeanFR_byCS(1,this_cumSum+1) = nanmean(firingRates(trialsWithThis_CS));



end % of cycling though each cum sum



return