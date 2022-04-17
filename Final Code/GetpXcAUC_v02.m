function [pXc_AUC,shuffled_pXc_AUC,SAME_postInsight_FR,DIFF_postInsight_FR] = GetpXcAUC_v02(tmp_spikeTables,RULE_SELECTIVE_MOMENTS)


meanFRs = nanmean(tmp_spikeTables.smoothedFRs(:,~isnan(RULE_SELECTIVE_MOMENTS)),2);
FeatureIndex = tmp_spikeTables.trialFeatures;

% go block by block and collect the 20 trials before a switch
blockIDs = unique(FeatureIndex.blockNum);
numblocks = sum(contains(FeatureIndex.blockStatus,'blockEnd'));
blockEnds = find(contains(FeatureIndex.blockStatus,'blockEnd'));
pXc_FRs = NaN(numblocks,31);
pXc_rules = NaN(numblocks,31);
rule_log=[];

% get overall pre/post insight AUCs
Pre_FRs = meanFRs(contains(FeatureIndex.rel2Eureka,'TenBeforeEureka'));
Post_FRs =meanFRs(contains(FeatureIndex.rel2Eureka,'TenAfterEureka'));
   
PreLabels = FeatureIndex.rule(contains(FeatureIndex.rel2Eureka,'TenBeforeEureka'));   
PostLabels = FeatureIndex.rule(contains(FeatureIndex.rel2Eureka,'TenAfterEureka')); 
[~,~,~,Pre_AUC] = perfcurve(PreLabels,Pre_FRs,'same');
[~,~,~,Post_AUC] = perfcurve(PostLabels,Post_FRs,'same');





block_rulesIsSAME=[];
for b_ix = 1:numblocks
    blockHolder = NaN(1,31);
    thisBlock = blockIDs(b_ix);
    thisBlockEnd = blockEnds(b_ix);
    
    % now cycle backward
    preAndPostInsightFR = NaN(1,20);
    preAndPostInsightRule = NaN(1,20);
    for ii = 0:19
       proposedTrial =  thisBlockEnd-ii;
        
       if proposedTrial > 0
        preAndPostInsightFR(ii+1) =    meanFRs(proposedTrial);
        
        if contains(FeatureIndex.rule(proposedTrial),'same')
            preAndPostInsightRule(ii+1) = 1;
                
        else
            preAndPostInsightRule(ii+1) = -1;
        end
        
       else
        preAndPostInsightFR(ii+1) =    NaN;
        preAndPostInsightRule(ii+1) =    NaN;
       end                 
    end
    
    preAndPostInsightFR = fliplr(preAndPostInsightFR);
       
    postSwitchFR = NaN(1,11);  
    postSwitchRule = NaN(1,11);
    for jj = 1:10
        p_trial = thisBlockEnd+jj;
        
        if p_trial <= numel(meanFRs)
          postSwitchFR(jj) =   meanFRs(p_trial);
          
        if contains(FeatureIndex.rule(p_trial),'same')
            postSwitchRule(jj) = 1;
        
        else
            postSwitchRule(jj) = -1;
        end
          
        else
          postSwitchFR(jj) =   NaN;
          postSwitchRule(jj) = NaN;
        end                   
    end
    
    

    
    numshifts = sum(isnan(blockHolder));
    blockHolder = circshift(blockHolder,numshifts);
    
    pXc_FRs(b_ix,:) = [preAndPostInsightFR,postSwitchFR];
    pXc_rules(b_ix,:) = [preAndPostInsightRule,postSwitchRule];
    if postSwitchRule(jj) == 1
       block_rulesIsSAME(b_ix)=1;
    else
       block_rulesIsSAME(b_ix)=0;
    end
    
end % of cycling through blocks
block_rulesIsSAME = logical(block_rulesIsSAME);

% shuffle the firing rates as a control
column_pXc_FRs = reshape(pXc_FRs,[],1);
shuffled_idx = randperm(numel(column_pXc_FRs));
column_shuffled_pXc_FRs = column_pXc_FRs(shuffled_idx);

% now reshape the column back into the blocked format
[n_col, n_row] = size(pXc_FRs);
shuffled_pXc_FRs = reshape(column_shuffled_pXc_FRs,n_col,n_row);

% now cycle through and do AUC
pXc_AUC = NaN(1,30);
shuffled_pXc_AUC = NaN(1,30);
for i = 1:29
    s = i+1;
    j = i+1;
     
    FRs_for_AUC = reshape(pXc_FRs(:,i:j),[],1);
    shuffledFRs_for_AUC = reshape(shuffled_pXc_FRs(:,i:j),[],1);
    lbl_for_AUC = reshape(pXc_rules(:,i:j),[],1);

    try
    [~,~,~,pXc_AUC(s)] = perfcurve(lbl_for_AUC,FRs_for_AUC,1); 
    [~,~,~,shuffled_pXc_AUC(s)] = perfcurve(lbl_for_AUC,shuffledFRs_for_AUC,1); 
 
    catch
     shuffled_pXc_AUC(s) = NaN;   
        if i < 10           
            pXc_AUC(s) = Pre_AUC;
        end
        if i > 10 & i < 22
            pXc_AUC(s) = Post_AUC;            
        end
    end % of try/catch
    
    if i == 20 | i == 19
       pXc_AUC(s) = Post_AUC;
    end  
end


 SAME_postInsight_FR = nanmean(pXc_FRs(block_rulesIsSAME,11:20))';
 DIFF_postInsight_FR = nanmean(pXc_FRs(~block_rulesIsSAME,11:20))';
 

 
  shuffled_pXc_AUC = smoothdata(shuffled_pXc_AUC,'movmean',3);

end % of function