%% Trials to criterion simulation
function [BlockLens, chance_p,ALL_ttc] = Trials2critSimv02(winsize,criterion,MinTrials,BinWidth)

% Thomas Elston - telston@nurhopsi.org

% INPUTS
% winsize   - how many recent trials should we keep track of?
% criterion - how many hits are required out of the winsize to reach crit?
% MinTrials - how many trials must have elapsed before evaluating whether
%             crit has been reached? Can be set to 1 if you don't care
%             about this.
% BinWidth  - when estimating the distribution/histogram, how wide should the bins
%             be? I generally use 5.

% OUTPUTS
% BlockLens - the x-axis for plotting the null distribution. Values here
%             are determined by the BinWidth input. 
% chance_p  - the y-axis for plotting the null distribution. This indicates
%             the proportion of performance-based reversals attained by a random,
%             binomial process as a function of BlockLens.
% ALL_ttc    - contains all trials to criterion. In other words, the raw
%             number of "trials" between reversals. 

ALL_ttc=[];

nboots = 1000;
for b_ix = 1:nboots

rng('shuffle')
for nn = 1:500
nn;
criterionmet = 0;
window = randi([0 1],1,winsize); %first X trials
ttc = winsize; %trials to criterion
while ~(criterionmet)
if (sum(window)>=criterion) && (ttc >=MinTrials)
    criterionmet = 1;
    break;
   
else
    % add 1 random trial
    window = [window(2:end) randi([0 1],1)];
    ttc = ttc+1;
end
end

allttc(nn,1) = ttc;
end


BlockLens = 10:BinWidth:500;
boot_p= histc(allttc,BlockLens)./nn;

p(b_ix,:) = boot_p;
ALL_ttc=[ALL_ttc;allttc];
end % of cycling through the bootstraps

chance_p = nanmean(p); % take the mean over all simulations to get the smoothed distribution




plot(BlockLens,p)
xlabel('Trials to criterion')
ylabel('rel. frequency')

return