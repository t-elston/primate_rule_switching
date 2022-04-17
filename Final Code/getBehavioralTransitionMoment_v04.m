function [FR_Change,BlockLens,BlockQdiffs,BlockFRs,BlockAha,BlockRules,upperCI] = getBehavioralTransitionMoment_v04(tmp_spikeTables)
firingRate_difference=[];
postEurekaFR = [];
preEurekaFR  = [];
priorBlockFRs= [];
h_g=[];
Aha_trialNums    = [];
blockLens        = [];
trialFeatures    = tmp_spikeTables.trialFeatures;
trialFRs         = tmp_spikeTables.smoothedFRs;
meanFRs          = nanmean(trialFRs(:,tmp_spikeTables.AssessedRuleSelectiveEpoch),2);
modelDifferences = trialFeatures.ModelConfidence;
SameEstimates    = trialFeatures.SameEstimates;
DiffEstimates    = trialFeatures.DiffEstimates;
cumSums          = trialFeatures.cumSum;




BlockQdiffs = {};
BlockFRs    = {};
BlockAha    = [];
BlockRules  = {};

% try it with Q learning
try
nrmlQsame = (trialFeatures.Qsame - min(trialFeatures.Qsame)) / (max(trialFeatures.Qsame) - min(trialFeatures.Qsame));
nrmlQdiff = (trialFeatures.Qdiff - min(trialFeatures.Qdiff)) / (max(trialFeatures.Qdiff) - min(trialFeatures.Qdiff));   
modelDifferences = smooth(mean([abs(nrmlQsame - nrmlQdiff),modelDifferences],2),2);
%  modelDifferences = smooth(abs(nrmlQsame - nrmlQdiff),2);

catch
    xx=[];
end

% try setting incorrect trials to NaNs
% incorrect_idx = contains(trialFeatures.outcome,'error');
% meanFRs(incorrect_idx) = NaN;

numTrialsForPreXPostComparison = 10;

   % standardize the font sizes
   lbl_fntSz = 14;
   ax_fntSz = 13;
   
   % standardize the line widths
   LW = 3;   
   % standardize axis line width
   ax_LW = 1;
   
CT =cbrewer('qual', 'Set1', 9);
SAME_c  = 2;
DIFF_c  = 1;

CT2 =cbrewer('qual', 'Accent', 8); 
CT3 =cbrewer('qual', 'Dark2', 8);  

% now let's go through each block
blockNums = unique(trialFeatures.blockNum);
numCompletedBlocks = sum(contains(trialFeatures.blockStatus,'blockEnd'));
nBoot = 1000; %number of bootstraps
 [bci,bmeans] = bootci(nBoot,{@mean,modelDifferences},'alpha',.05); %95 confidence interval

 
ShuffledFR_diffs = NaN(numCompletedBlocks-1,nBoot);
ShuffledBLs = NaN(numCompletedBlocks-1,nBoot);

BlockTransitionCounter = 0;
for b_ix = 2:numCompletedBlocks
    BlockTransitionCounter = BlockTransitionCounter+1;
    thisBlock_ID = blockNums(b_ix);
    thisBlock_trial_idx = trialFeatures.blockNum == thisBlock_ID;
    thisBlock_Model_diffs = modelDifferences(thisBlock_trial_idx);
    thisBlock_cumSums     = cumSums(thisBlock_trial_idx);
    thisBlock_SAME_estimates = trialFeatures.SameEstimates(thisBlock_trial_idx);
    thisBlock_DIFF_estimates = trialFeatures.DiffEstimates(thisBlock_trial_idx);
    thisBlockFRs = meanFRs(thisBlock_trial_idx);
    thisBlockRule = unique(trialFeatures.rule(thisBlock_trial_idx));

    
   
    
%     hold on
%     plot(thisBlock_SAME_estimates)
%     plot(thisBlock_DIFF_estimates)

    % get the mean firing rate from the previous block's last 10 trials
firstTrialThisBlock = min(find(thisBlock_trial_idx));
lastTrial_thisBlock = max(find(thisBlock_trial_idx));


    % the switch trial should be the first instance where the model
    % exceeded the upper ci
    upperCI = max(bci);
    trialsUntilAha = min(find(thisBlock_Model_diffs >= upperCI));
    Aha_trial = find(modelDifferences >= upperCI & thisBlock_trial_idx);
    if ~isempty(Aha_trial)
    Aha_trial =Aha_trial(1);
    
    % get the mean FR of the X trials starting from the Aha_trial
    if Aha_trial+numTrialsForPreXPostComparison > lastTrial_thisBlock
        Aha_end = lastTrial_thisBlock;
    else
        Aha_end = Aha_trial+numTrialsForPreXPostComparison;
    end
    
    if (Aha_trial-5) > 0
    pre_Aha_FR  = nanmean(meanFRs(Aha_trial-5:Aha_trial));
    else
        pre_Aha_FR  = nanmean(meanFRs(1:Aha_trial));
    end
    post_Aha_FR = nanmean(meanFRs(Aha_trial:Aha_end));
        
    priorBlockStart = [];
    % if there were less than 10 available trials in the prior block
    if firstTrialThisBlock-numTrialsForPreXPostComparison < 1
        priorBlockStart = 1; % this would only happen for the first block the cell was present for      
    else
        priorBlockStart = firstTrialThisBlock-numTrialsForPreXPostComparison;        
    end
    mean_priorBlockFR = nanmean(meanFRs(priorBlockStart:firstTrialThisBlock-1));
        
    priorBlock_FiringRates = meanFRs(priorBlockStart:firstTrialThisBlock-1);
    post_AHA_firingRates = meanFRs(Aha_trial:Aha_end);

    
      
    
   preEurekaFR(BlockTransitionCounter) = pre_Aha_FR;
   postEurekaFR(BlockTransitionCounter) = post_Aha_FR;
   priorBlockFRs(BlockTransitionCounter) = mean_priorBlockFR;
   firingRate_difference(BlockTransitionCounter) =  abs(post_Aha_FR-pre_Aha_FR);
   Aha_trialNums(BlockTransitionCounter)         =  trialsUntilAha;
   BlockRules(BlockTransitionCounter) = thisBlockRule;
   blockLens(BlockTransitionCounter) = lastTrial_thisBlock - firstTrialThisBlock;
   
   
   % get relevant bits
       Conf = modelDifferences(priorBlockStart:Aha_end);
       conf_x = 1:numel(Conf);
       Aha_spot = min(find(conf_x' > 10 & Conf >= upperCI));
       FRs = (meanFRs(priorBlockStart:Aha_end));
       
   % save some info about this block for nice plotting later
    BlockQdiffs{BlockTransitionCounter,1} = Conf;
    BlockFRs{BlockTransitionCounter,1}    = FRs;
    BlockAha(BlockTransitionCounter,1)    = Aha_spot;
       
   % do some sanity-check plotting
   block_fig = figure;
   set(block_fig, 'Position', [100 100 350 350]); 
   hold on
    plot(Conf,'LineWidth',LW,'color','k'); 
    plot([1 abs(priorBlockStart-Aha_end)+1],[upperCI upperCI],'color',CT(9,:),'LineWidth',LW/2,'LineStyle','-.');
    plot([Aha_spot Aha_spot],[upperCI upperCI],'+','color',CT(1,:),'LineWidth',LW/1,'MarkerSize',20);
     ylabel('| Qsame - Qdiff |','FontSize',lbl_fntSz);
      ylim([0 1]);
     yticks([0 : max(ylim)/2 : max(ylim)]);
     axis tight;
    yyaxis right
    plot((FRs),'LineWidth',LW,'color',CT2(5,:));
     ylim([0 50]);
     yticks([0 25 50]);
    plot([10 10],[min(ylim) max(ylim)],'k','LineWidth',LW/2,'LineStyle','-');
    
    

    


   [lgd,lgd_props]=  legend({'Model Confidence','95th percentile','Firing Rate'},'FontSize',lbl_fntSz);
    unitAUC_Lines=findobj(lgd_props,'type','line');  % get the lines, not text
         set(unitAUC_Lines,'linewidth',LW);            % set their width property
         legend boxoff
    
    
    xlabel('Trials Relative to Switch','FontSize',lbl_fntSz);
    ylabel('Firing Rate (Hz)','FontSize',lbl_fntSz);
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    ax.FontSize = ax_fntSz;
    ax.LineWidth = ax_LW;
    xlim([1 abs(priorBlockStart-Aha_end)+1]);
    xticklabels(xticks-10);
    hold off

     end  
  
end % of going through each block

[real_corr,p] = corr(abs(postEurekaFR-priorBlockFRs)', blockLens');

BlockLens = blockLens';
FR_Change = abs(postEurekaFR-priorBlockFRs)';
   
return