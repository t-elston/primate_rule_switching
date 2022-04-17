function [preEurekaFR,postEurekaFR,priorBlockFRs, Aha_trialNums,transitionRules, blockLens,h_g,shuffledCorrs] =...
                                                                 getBehavioralTransitionMoment_v03(meanFRs,trialFeatures)
firingRate_difference=[];
postEurekaFR = [];
preEurekaFR  = [];
priorBlockFRs= [];
h_g=[];
Aha_trialNums    = [];
blockLens        = [];
modelDifferences = trialFeatures.ModelConfidence;
SameEstimates    = trialFeatures.SameEstimates;
DiffEstimates    = trialFeatures.DiffEstimates;
cumSums          = trialFeatures.cumSum;

% try it with Q learning
try
modelDifferences = abs(trialFeatures.Qsame - trialFeatures.Qdiff);
catch
    xx=[];
end

 numTrialsForPreXPostComparison = 10; % Joni suggested switching to 10 trials from 5 for more stability

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
%     thisBlock_cumSums     = cumSums(thisBlock_trial_idx);
%     thisBlock_SAME_estimates = trialFeatures.SameEstimates(thisBlock_trial_idx);
%     thisBlock_DIFF_estimates = trialFeatures.DiffEstimates(thisBlock_trial_idx);
    thisBlockFRs = meanFRs(thisBlock_trial_idx);
    thisBlockRule = unique(trialFeatures.rule(thisBlock_trial_idx));

    
   
    
%     hold on
%     plot(thisBlock_SAME_estimates)
%     plot(thisBlock_DIFF_estimates)

    % get the mean firing rate from the previous block's last 5 trials
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
    h_struct = mes(priorBlock_FiringRates,post_AHA_firingRates,'hedgesg','nBoot',1000);
    h_g(BlockTransitionCounter)=h_struct.hedgesg;
    
      
    
   preEurekaFR(BlockTransitionCounter) = pre_Aha_FR;
   postEurekaFR(BlockTransitionCounter) = post_Aha_FR;
   priorBlockFRs(BlockTransitionCounter) = mean_priorBlockFR;
   firingRate_difference(BlockTransitionCounter) =  abs(post_Aha_FR-pre_Aha_FR);
   Aha_trialNums(BlockTransitionCounter)         =  trialsUntilAha;
   transitionRules(BlockTransitionCounter) = thisBlockRule;
   blockLens(BlockTransitionCounter) = lastTrial_thisBlock - firstTrialThisBlock;
   
%    % do some sanity-check plotting
%    block_fig = figure;
%    set(block_fig, 'Position', [100 100 350 350]); 
%    hold on
%     Conf = modelDifferences(priorBlockStart:Aha_end);
%     conf_x = 1:numel(Conf);
%     plot(Conf,'LineWidth',LW,'color','k'); 
%     plot([1 abs(priorBlockStart-Aha_end)+1],[upperCI upperCI],'color',CT(9,:),'LineWidth',LW/2,'LineStyle','-.');
%     Aha_spot = min(find(conf_x' > 10 & Conf >= upperCI));
%     plot([Aha_spot Aha_spot],[upperCI upperCI],'+','color',CT(1,:),'LineWidth',LW/1,'MarkerSize',20);
%      ylabel('Model Confidence','FontSize',lbl_fntSz);
%      ylim([0 1]);
%      yticks([0 : max(ylim)/2 : max(ylim)]);
%      axis tight;
%     yyaxis right
%     FRs = (meanFRs(priorBlockStart:Aha_end));
%     plot((FRs),'LineWidth',LW,'color',CT2(5,:));
%     ylim([0 50]);
%     yticks([0 25 50]);
%     plot([10 10],[min(ylim) max(ylim)],'k','LineWidth',LW/2,'LineStyle','-');
% 
% 
% %    [lgd,lgd_props]=  legend({'Model Confidence','95th percentile','Firing Rate'},'FontSize',lbl_fntSz);
% %     unitAUC_Lines=findobj(lgd_props,'type','line');  % get the lines, not text
% %          set(unitAUC_Lines,'linewidth',LW);            % set their width property
% %          legend boxoff
% %     
%     
%     xlabel('Trials Relative to Switch','FontSize',lbl_fntSz);
%     ylabel('Firing Rate (Hz)','FontSize',lbl_fntSz);
%     ax = gca;
%     ax.YAxis(1).Color = 'k';
%     ax.YAxis(2).Color = 'k';
%     ax.FontSize = ax_fntSz;
%     ax.LineWidth = ax_LW;
%     xlim([1 abs(priorBlockStart-Aha_end)+1]);
%     xticklabels(xticks-10);
%     hold off

     end  
    
    %%%%% NOW DO THE PERMUTATIONS
    permuted_aha = randi(lastTrial_thisBlock-firstTrialThisBlock,1,nBoot) +firstTrialThisBlock;
    for b_ix = 1:nBoot
        p_Aha_trial = permuted_aha(b_ix);
        % get the mean FR of the X trials starting from the Aha_trial
    if p_Aha_trial+numTrialsForPreXPostComparison > lastTrial_thisBlock
        p_Aha_end = lastTrial_thisBlock;
    else
        p_Aha_end = p_Aha_trial+numTrialsForPreXPostComparison;
    end
    
    p_idx = sort([p_Aha_trial p_Aha_end]);
    p_post_Aha_FR = nanmean(meanFRs(p_idx(1):p_idx(2)));
    
    try
    ShuffledFR_diffs(BlockTransitionCounter,b_ix) = abs(p_post_Aha_FR -  mean_priorBlockFR);
    catch
    ShuffledFR_diffs(BlockTransitionCounter,b_ix) = abs(p_post_Aha_FR -  0);
    end
    end % of getting data for each permutation
       
end % of going through each block

% [real_corr,p] = corr(abs(preEurekaFR-priorBlockFRs)', blockLens');
% [real_corr,p] = corr(abs(firingRate_difference)', blockLens');
[real_corr,p] = corr(h_g', blockLens');
% 

shuffledCorrs =NaN(1,nBoot); 
for i = 1:nBoot
    s_ix = randperm(numel(blockLens));
    s_BL = blockLens(s_ix)';
    s_FR = ShuffledFR_diffs(:,i);
    try
 [shuffledCorrs(1,i),~] = corr(s_FR, s_BL);  
    catch
      shuffledCorrs(1,i) = NaN;
    end
        
end

% BlockLens = blockLens';
% FR_Change = abs(postEurekaFR-priorBlockFRs)';
%  BLxFR_mdl = fitlm(BlockLens,FR_Change);
%  
% 
%  
%          BL_b = BLxFR_mdl.Coefficients.Estimate(2);
%          BL_int = BLxFR_mdl.Coefficients.Estimate(1);
         
%    BL_fig = figure;
%    set(BL_fig, 'Position', [100 100 700 700]);
%   hold on
%   
%   s_ix= contains(transitionRules,'same');  
%   plot(BlockLens(s_ix),FR_Change(s_ix),'o','color',CT(SAME_c,:),'LineWidth',LW,...
%                 'MarkerFaceColor',CT(SAME_c,:),'MarkerEdgeColor',CT(SAME_c,:),'MarkerSize',20);
%   plot(BlockLens(~s_ix),FR_Change(~s_ix),'o','color',CT(DIFF_c,:),'LineWidth',LW,...
%                 'MarkerFaceColor',CT(DIFF_c,:),'MarkerEdgeColor',CT(DIFF_c,:),'MarkerSize',20);
%             
% plot([min(xlim) max(xlim)],[(min(xlim)*BL_b)+BL_int (max(xlim)*BL_b)+BL_int],'k','LineWidth',6);
% 
%                 plot(BlockLens(s_ix),FR_Change(s_ix),'o','color',CT(SAME_c,:),'LineWidth',LW,...
%                 'MarkerFaceColor',CT(SAME_c,:),'MarkerEdgeColor',CT(SAME_c,:),'MarkerSize',20);
%   plot(BlockLens(~s_ix),FR_Change(~s_ix),'o','color',CT(DIFF_c,:),'LineWidth',LW,...
%                 'MarkerFaceColor',CT(DIFF_c,:),'MarkerEdgeColor',CT(DIFF_c,:),'MarkerSize',20);
%    
%  
% %    ylim([0 25]);
%    xlabel('Block Length','FontSize',lbl_fntSz);
%    ylabel('|\Delta Firing Rate| (Hz)','FontSize',lbl_fntSz);
%    ylim([0 30]);
%    yticks([0 : max(ylim)/2 : max(ylim)]);
%    xticks([0 : max(xlim)/2 : max(xlim)]);
%     ax = gca;
%     ax.FontSize = ax_fntSz;

%     ax.LineWidth = ax_LW;
%     set(gcf,'renderer','Painters');


return