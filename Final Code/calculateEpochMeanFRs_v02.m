function [SelectivityTable,RandomFeedbackTrials] = calculateEpochMeanFRs_v02(SelectivityTable)

 EpochsToAssess =  fieldnames(SelectivityTable);
 RandomFeedbackTrials=[];

for epoch_ix = 1:numel(EpochsToAssess)

for unit_ix = 1:numel(SelectivityTable.(EpochsToAssess{epoch_ix}).neuronName)
    thisUnitName =  SelectivityTable.(EpochsToAssess{epoch_ix}).neuronName(unit_ix);
    % now load the data from that unit
    thisUnitData=[];
    thisUnitData = load([thisUnitName{1} '.mat']);
    thisUnitData = thisUnitData.thisUnitData;    
    FeedbackPeriodMeanFRs = (nanmean(thisUnitData.(EpochsToAssess{epoch_ix}).normalizedFRs(:,500:800),2));   
    TrialFeatures      =   thisUnitData.(EpochsToAssess{epoch_ix}).trialFeatures;
    numTrialsCompleted = numel(FeedbackPeriodMeanFRs);
     
    % now get the firing rates for the insight trials   
    InsightTrials = find(contains(TrialFeatures.blockStatus,'blockEnd'))-9;  
    % find falsely labelled insight moments
    impossibleInsight = InsightTrials < 1 | InsightTrials > numel(FeedbackPeriodMeanFRs);
    InsightTrials(impossibleInsight)=[];
    numInsights = numel(InsightTrials);
    
    % now get the firing rates of those trials and the rules of those
    % trials
    InsightFiringRates = FeedbackPeriodMeanFRs(InsightTrials);
    InsightRules       = TrialFeatures.rule(InsightTrials);
    SameFeedBackInsightFR = nanmean(InsightFiringRates(contains(InsightRules,'same')));
    DiffFeedBackInsightFR = nanmean(InsightFiringRates(contains(InsightRules,'diff')));
    
    SelectivityTable.(EpochsToAssess{epoch_ix}).SameFeedbackInsightFR(unit_ix) = SameFeedBackInsightFR;
    SelectivityTable.(EpochsToAssess{epoch_ix}).DiffFeedbackInsightFR(unit_ix) = DiffFeedBackInsightFR;
    
    nboots = 1000;
    randomTrial_idx = randi(numTrialsCompleted,[numInsights nboots]);
    % remove and replace the real insight trials
     r_ix = randomTrial_idx == InsightTrials;
     randomTrial_idx(r_ix) = randomTrial_idx(r_ix) - 5;
     randomTrial_idx(randomTrial_idx<=0) = 2; 
    this_boot_sameFR = NaN(1,nboots);
    this_boot_diffFR = NaN(1,nboots);
    for boot_ix = 1:nboots
        this_boot_FRs = FeedbackPeriodMeanFRs(randomTrial_idx(:,boot_ix));
        this_boot_rules = thisUnitData.(EpochsToAssess{epoch_ix}).trialFeatures.rule(randomTrial_idx(:,boot_ix));
        
        this_boot_sameFR(1,boot_ix) = nanmean(this_boot_FRs(contains(this_boot_rules,'same')));
        this_boot_diffFR(1,boot_ix) = nanmean(this_boot_FRs(contains(this_boot_rules,'diff')));
    end

    SelectivityTable.(EpochsToAssess{epoch_ix}).ShuffledSAMEInsightFR(unit_ix,:) = {this_boot_sameFR};
    SelectivityTable.(EpochsToAssess{epoch_ix}).ShuffledDIFFInsightFR(unit_ix,:) = {this_boot_diffFR};  
    
    
    
      % find the pre insight errors and AUCs
      error_ix =  find(contains(thisUnitData.(EpochsToAssess{epoch_ix}).trialFeatures.outcome,'error'));  
      B_1_FRs=[];
      A_1_FRs=[];
      B_1_rules=[];
      A_1_rules=[];
      B_2_FRs=[];
      A_2_FRs=[];
      B_2_rules=[];
      A_2_rules=[];
     
      First_error=[];
      Second_error=[];
     for i = 1:numInsights
         this_insight = InsightTrials(i);
         ErrorsBeforeThisInsight = error_ix(error_ix < this_insight);
         ErrorsBeforeThisInsight = sort(ErrorsBeforeThisInsight,'descend');
         if ~isempty(ErrorsBeforeThisInsight)
         First_error(i) = ErrorsBeforeThisInsight(1);
         if numel(ErrorsBeforeThisInsight) < 2
          Second_error(i) = ErrorsBeforeThisInsight(1);  
         else
         Second_error(i) = ErrorsBeforeThisInsight(2);
         end
                  % now get the firing rates and rules for the adjacent trials
        [xB_1_FRs,xA_1_FRs,xB_1_rules,xA_1_rules,xB_2_FRs,xA_2_FRs,xB_2_rules,xA_2_rules] =...
                calculateAUC_rel2Trial_v01(FeedbackPeriodMeanFRs,TrialFeatures,ErrorsBeforeThisInsight);
         end
        
    B_1_FRs   = [B_1_FRs;xB_1_FRs];  
    A_1_FRs   = [A_1_FRs;xA_1_FRs];
    B_1_rules = [B_1_rules; xB_1_rules];
    A_1_rules = [A_1_rules; xA_1_rules];
    
    B_2_FRs   = [B_2_FRs;xB_2_FRs];  
    A_2_FRs   = [A_2_FRs;xA_2_FRs];
    B_2_rules = [B_2_rules; xB_2_rules];
    A_2_rules = [A_2_rules; xA_2_rules];
    
     end

     InsightRules(First_error<1)=[];
     First_error(First_error<1)=[];
     Second_error(Second_error<1)=[];
 
     FirstError_FR  = FeedbackPeriodMeanFRs(First_error);
     SecondError_FR = FeedbackPeriodMeanFRs(Second_error);
     
     SelectivityTable.(EpochsToAssess{epoch_ix}).SameFirstError_FR(unit_ix) =...
                                           nanmean(FirstError_FR(contains(InsightRules,'same')));
     SelectivityTable.(EpochsToAssess{epoch_ix}).DiffFirstError_FR(unit_ix) =...
                                           nanmean(FirstError_FR(contains(InsightRules,'diff')));
     
SelectivityTable.(EpochsToAssess{epoch_ix}).SameSecondError_FR(unit_ix) =...
                                          nanmean(SecondError_FR(contains(InsightRules,'same')));
SelectivityTable.(EpochsToAssess{epoch_ix}).DiffSecondError_FR(unit_ix) =...
                                          nanmean(SecondError_FR(contains(InsightRules,'diff')));
try     
[~,~,~,SelectivityTable.(EpochsToAssess{epoch_ix}).FirstError_PreAUC(unit_ix)] = perfcurve(B_1_rules,B_1_FRs+001,1);
[~,~,~,SelectivityTable.(EpochsToAssess{epoch_ix}).FirstError_PostAUC(unit_ix)] = perfcurve(A_1_rules,A_1_FRs+001,1);
[~,~,~,SelectivityTable.(EpochsToAssess{epoch_ix}).SecondError_PreAUC(unit_ix)] = perfcurve(B_2_rules,B_2_FRs+001,1);
[~,~,~,SelectivityTable.(EpochsToAssess{epoch_ix}).SecondError_PostAUC(unit_ix)] = perfcurve(A_2_rules,A_2_FRs+001,1);
catch
   xx=[]; 
end
      
      % now save these control analyses
      
      
      
end % of going through each unit in each epoch

end % of assessing each epoch




return