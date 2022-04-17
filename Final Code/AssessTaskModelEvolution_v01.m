function [EnsemblesOverTime] = AssessTaskModelEvolution_v01(use_perms,monkey,plotFigs,DATADIR);
% I want to simply count the number of rule, image, and action cells at
% each time step during periods of high and low performance. 
EnsemblesOverTime=struct;

   CT=cbrewer('qual', 'Set1', 9);

% read in the data (.mat files)
fileList = dir(fullfile(DATADIR, '*.mat'));
FileNames = {fileList.name};

switch monkey    
    case 'Grover'
            files2use = contains(FileNames,'G');
            FileNames = FileNames(files2use);
        
    case 'Ziggy'
            files2use = contains(FileNames,'Z');
            FileNames = FileNames(files2use);        
end % of switch statement

% remove the behavioral data part
FileNames(contains(FileNames,'BehavioralData')) = [];
FileNames(contains(FileNames,'SelectivityTable')) = [];

% let's start by looking at the high-perf period
BeforeRULE_ENSEMBLE  = NaN(numel(FileNames),2700);
BeforeIMAGE_ENSEMBLE = NaN(numel(FileNames),2700);
BeforeACTION_ENSEMBLE= NaN(numel(FileNames),2700);
PB_RE = NaN(numel(FileNames),2700);
PB_IE = NaN(numel(FileNames),2700);
PB_AE = NaN(numel(FileNames),2700);







for f_ix = 1:numel(FileNames)
    thisUnitData = load([FileNames{f_ix}]);    
    thisUnitData = thisUnitData.thisUnitData;   
    
    % normal data
    % pre eureka
    % before choice
    % periods of selectivity
   try
    PB_RE(f_ix,:)                 = thisUnitData.beforeChoice.PRE_RuleSelectiveEpochs;
    PB_IE(f_ix,:)                 = thisUnitData.beforeChoice.PRE_SampleSelectiveEpochs;
    PB_AE(f_ix,:)                 = thisUnitData.beforeChoice.PRE_ActionSelectiveEpochs;  
    
    % effect sizes
%     LowPerf_RuleBetas(f_ix,:)          = thisUnitData.beforeChoice.LowPerf_RuleBetaWeight;
%     LowPerf_ImageBetas(f_ix,:)          = thisUnitData.beforeChoice.LowPerf_SampleBetaWeight;
%     LowPerf_ActionBetas(f_ix,:)          = thisUnitData.beforeChoice.LowPerf_ActionBetaWeight;
        
    % post eureka
    % before choice
    BeforeRULE_ENSEMBLE(f_ix,:)   = thisUnitData.beforeChoice.AllRuleSelectiveEpochs;
    BeforeIMAGE_ENSEMBLE(f_ix,:)  = thisUnitData.beforeChoice.AllSampleSelectiveEpochs;
    BeforeACTION_ENSEMBLE(f_ix,:) = thisUnitData.beforeChoice.AllActionSelectiveEpochs;
    
    % effect sizes
%     HiPerf_RuleBetas(f_ix,:)          = thisUnitData.beforeChoice.HiPerf_RuleBetaWeight;
%     HiPerf_ImageBetas(f_ix,:)          = thisUnitData.beforeChoice.HiPerf_SampleBetaWeight;
%     HiPerf_ActionBetas(f_ix,:)          = thisUnitData.beforeChoice.HiPerf_ActionBetaWeight;
    
     
%     % shuffled data
    % pre eureka
    % before choice
 if  use_perms
    S_P_BR(f_ix,:)                = double(thisUnitData.beforeChoice.ShuffledPRE_RuleSelectiveEpochs);
    S_P_BI(f_ix,:)                = double(thisUnitData.beforeChoice.ShuffledPRE_SampleSelectiveEpochs);
    S_P_BA(f_ix,:)                = double(thisUnitData.beforeChoice.ShuffledPRE_ActionSelectiveEpochs);  
    
        % effect sizes
%     S_LowPerf_RuleBetas(f_ix,:)          = smooth(thisUnitData.beforeChoice.ShuffledLowPerf_RuleBetaWeight,100);
%     S_LowPerf_ImageBetas(f_ix,:)          = smooth(thisUnitData.beforeChoice.ShuffledLowPerf_SampleBetaWeight,100);
%     S_LowPerf_ActionBetas(f_ix,:)          = smooth(thisUnitData.beforeChoice.ShuffledLowPerf_ActionBetaWeight,100);
    
        
    % post eureka
    % before choice
    S_BR(f_ix,:)                = double(thisUnitData.beforeChoice.ShuffledAllRuleSelectiveEpochs);
    S_BI(f_ix,:)                = double(thisUnitData.beforeChoice.ShuffledAllSampleSelectiveEpochs);
    S_BA(f_ix,:)                = double(thisUnitData.beforeChoice.ShuffledAllActionSelectiveEpochs);    
    
    % effect sizes
%     S_HiPerf_RuleBetas(f_ix,:)          = smooth(thisUnitData.beforeChoice.ShuffledHiPerf_RuleBetaWeight,100);
%     S_HiPerf_ImageBetas(f_ix,:)          = smooth(thisUnitData.beforeChoice.ShuffledHiPerf_SampleBetaWeight,100);
%     S_HiPerf_ActionBetas(f_ix,:)          = smooth(thisUnitData.beforeChoice.ShuffledHiPerf_ActionBetaWeight,100);
  end
   catch
   end

end % of cycling through each neuron


% express the data as fractions of the total number of units in the
% ensemble

BeforeRULE_units = nansum(BeforeRULE_ENSEMBLE,2)>0;
BeforeIMAGE_units = nansum(BeforeIMAGE_ENSEMBLE,2)>0;
BeforeACTION_units = nansum(BeforeACTION_ENSEMBLE,2)>0;

Low_perf_rule_units = nansum(PB_RE,2)>0;

% look at the low perf units
LP_B_rule_units   = nansum(PB_RE,2)>0 & BeforeRULE_units;
LP_B_image_units  = nansum(PB_IE,2)>0 & BeforeIMAGE_units;
LP_B_action_units = nansum(PB_AE,2)>0 & BeforeACTION_units;

RULE_n = sum(BeforeRULE_units);
IMAGE_n = sum(BeforeIMAGE_units);
ACTION_n = sum(BeforeACTION_units);

% % assess the effect sizes over time
% % normal data
% [HiPerfRule_beta_means HiPerfRule_beta_SEMs] = calculateColumnMeansSEM_v01(HiPerf_RuleBetas(BeforeRULE_units,:));
% [HiPerfImage_beta_means HiPerfImage_beta_SEMs] = calculateColumnMeansSEM_v01(HiPerf_ImageBetas(BeforeIMAGE_units,:));
% [HiPerfAction_beta_means HiPerfAction_beta_SEMs] = calculateColumnMeansSEM_v01(HiPerf_ActionBetas(BeforeACTION_units,:));
% 
% [LowPerfRule_beta_means LowPerfRule_beta_SEMs] = calculateColumnMeansSEM_v01(LowPerf_RuleBetas(BeforeRULE_units,:));
% [LowPerfImage_beta_means LowPerfImage_beta_SEMs] = calculateColumnMeansSEM_v01(LowPerf_ImageBetas(BeforeIMAGE_units,:));
% [LowPerfAction_beta_means LowPerfAction_beta_SEMs] = calculateColumnMeansSEM_v01(LowPerf_ActionBetas(BeforeACTION_units,:));
% 
% % shuffled data
%  if  use_perms
% [S_HiPerfRule_beta_means S_HiPerfRule_beta_SEMs] = calculateColumnMeansSEM_v01(S_HiPerf_RuleBetas(BeforeRULE_units,:));
% [S_HiPerfImage_beta_means S_HiPerfImage_beta_SEMs] = calculateColumnMeansSEM_v01(S_HiPerf_ImageBetas(BeforeIMAGE_units,:));
% [S_HiPerfAction_beta_means S_HiPerfAction_beta_SEMs] = calculateColumnMeansSEM_v01(S_HiPerf_ActionBetas(BeforeACTION_units,:));
% 
% [S_LowPerfRule_beta_means S_LowPerfRule_beta_SEMs] = calculateColumnMeansSEM_v01(S_LowPerf_RuleBetas(BeforeRULE_units,:));
% [S_LowPerfImage_beta_means S_LowPerfImage_beta_SEMs] = calculateColumnMeansSEM_v01(S_LowPerf_ImageBetas(BeforeIMAGE_units,:));
% [S_LowPerfAction_beta_means S_LowPerfAction_beta_SEMs] = calculateColumnMeansSEM_v01(S_LowPerf_ActionBetas(BeforeACTION_units,:));
%  end








smooth_span = 20;
filterType = 'movmean';
% NORMAL DATA
% pre eureka
% before choice
PB_R_dxdt = smoothdata(nansum(PB_RE(LP_B_rule_units,:),1)/RULE_n,filterType,smooth_span);
PB_I_dxdt = smoothdata(nansum(PB_IE(LP_B_image_units,:),1)/RULE_n,filterType,smooth_span);
PB_A_dxdt = smoothdata(nansum(PB_AE(LP_B_action_units,:),1)/RULE_n,filterType,smooth_span);

% after choice
% PA_R_dxdt = smoothdata(nansum(PA_RE,1)/RULE_n,filterType,smooth_span);
% PA_I_dxdt = smoothdata(nansum(PA_IE,1)/IMAGE_n,filterType,smooth_span);
% PA_A_dxdt = smoothdata(nansum(PA_AE,1)/ACTION_n,filterType,smooth_span);


% post eureka
% before choice
BeforeRULE_DXDT   = smoothdata(nansum(BeforeRULE_ENSEMBLE,1)/RULE_n,filterType,smooth_span);
BeforeIMAGE_DXDT  = smoothdata(nansum(BeforeIMAGE_ENSEMBLE,1)/IMAGE_n,filterType,smooth_span);
BeforeACTION_DXDT = smoothdata(nansum(BeforeACTION_ENSEMBLE,1)/ACTION_n,filterType,smooth_span);

% after choice
% AfterRULE_DXDT    = smoothdata(nansum(AfterRULE_ENSEMBLE,1)/RULE_n,filterType,smooth_span);
% AfterIMAGE_DXDT   = smoothdata(nansum(AfterIMAGE_ENSEMBLE,1)/IMAGE_n,filterType,smooth_span);
% AfterACTION_DXDT  = smoothdata(nansum(AfterACTION_ENSEMBLE,1)/ACTION_n,filterType,smooth_span);

% SHUFFLED DATA
 if  use_perms
% pre eureka
% before choice
S_P_BR_dxdt      = smoothdata(nansum(S_P_BR,1)/RULE_n,filterType,smooth_span);
S_P_BI_dxdt      = smoothdata(nansum(S_P_BI,1)/IMAGE_n,filterType,smooth_span);
S_P_BA_dxdt      = smoothdata(nansum(S_P_BA,1)/ACTION_n,filterType,smooth_span);
% 
% % after choice
% S_P_AR_dxdt      = smoothdata(nansum(S_P_AR,1)/RULE_n,filterType,smooth_span);
% S_P_AI_dxdt      = smoothdata(nansum(S_P_AI,1)/IMAGE_n,filterType,smooth_span);
% S_P_AA_dxdt      = smoothdata(nansum(S_P_AA,1)/ACTION_n,filterType,smooth_span);
% 
% % post eureka
% % before choice
S_BR_dxdt      = smoothdata(nansum(S_BR,1)/RULE_n,filterType,smooth_span);
S_BI_dxdt      = smoothdata(nansum(S_BI,1)/IMAGE_n,filterType,smooth_span);
S_BA_dxdt      = smoothdata(nansum(S_BA,1)/ACTION_n,filterType,smooth_span);
% 
% S_AR_dxdt      = smoothdata(nansum(S_AR,1)/RULE_n,filterType,smooth_span);
% S_AI_dxdt      = smoothdata(nansum(S_AI,1)/IMAGE_n,filterType,smooth_span);
% S_AA_dxdt      = smoothdata(nansum(S_AA,1)/ACTION_n,filterType,smooth_span);
 end
%---------------------------------------------------------------------------


% save the data
% normal data
EnsemblesOverTime.PreInsight.Fraction.Rule   = PB_R_dxdt;
EnsemblesOverTime.PreInsight.Fraction.Image  = PB_I_dxdt;
EnsemblesOverTime.PreInsight.Fraction.Action = PB_A_dxdt;

% EnsemblesOverTime.PreInsight.pW2.Rule_mean   = LowPerfRule_beta_means;
% EnsemblesOverTime.PreInsight.pW2.Rule_sem     = LowPerfRule_beta_SEMs;
% EnsemblesOverTime.PreInsight.pW2.Image_mean   = LowPerfImage_beta_means;
% EnsemblesOverTime.PreInsight.pW2.Image_sem    = LowPerfImage_beta_SEMs;
% EnsemblesOverTime.PreInsight.pW2.Action_mean   = LowPerfAction_beta_means;
% EnsemblesOverTime.PreInsight.pW2.Action_sem    = LowPerfAction_beta_SEMs;

EnsemblesOverTime.PostInsight.Fraction.Rule   = BeforeRULE_DXDT;
EnsemblesOverTime.PostInsight.Fraction.Image  = BeforeIMAGE_DXDT;
EnsemblesOverTime.PostInsight.Fraction.Action = BeforeACTION_DXDT;

% EnsemblesOverTime.PostInsight.pW2.Rule_mean   = HiPerfRule_beta_means;
% EnsemblesOverTime.PostInsight.pW2.Rule_sem    = HiPerfRule_beta_SEMs;
% EnsemblesOverTime.PostInsight.pW2.Image_mean  = HiPerfImage_beta_means;
% EnsemblesOverTime.PostInsight.pW2.Image_sem   = HiPerfImage_beta_SEMs;
% EnsemblesOverTime.PostInsight.pW2.Action_mean = HiPerfAction_beta_means;
% EnsemblesOverTime.PostInsight.pW2.Action_sem  = HiPerfAction_beta_SEMs;

% save the shuffled data
if use_perms
    
EnsemblesOverTime.PreInsight.Fraction.S_Rule    = S_P_BR_dxdt;
EnsemblesOverTime.PreInsight.Fraction.S_Image   = S_P_BI_dxdt;
EnsemblesOverTime.PreInsight.Fraction.S_Action  = S_P_BA_dxdt;

% EnsemblesOverTime.PreInsight.pW2.S_Rule_mean    = S_LowPerfRule_beta_means;
% EnsemblesOverTime.PreInsight.pW2.S_Rule_sem     = S_LowPerfRule_beta_SEMs;
% EnsemblesOverTime.PreInsight.pW2.S_Image_mean   = S_LowPerfImage_beta_means;
% EnsemblesOverTime.PreInsight.pW2.S_Image_sem    = S_LowPerfImage_beta_SEMs;
% EnsemblesOverTime.PreInsight.pW2.S_Action_mean  = S_LowPerfAction_beta_means;
% EnsemblesOverTime.PreInsight.pW2.S_Action_sem   = S_LowPerfAction_beta_SEMs;

EnsemblesOverTime.PostInsight.Fraction.S_Rule   = S_BR_dxdt;
EnsemblesOverTime.PostInsight.Fraction.S_Image  = S_BI_dxdt;
EnsemblesOverTime.PostInsight.Fraction.S_Action = S_BA_dxdt;

% EnsemblesOverTime.PostInsight.pW2.S_Rule_mean   = S_HiPerfRule_beta_means;
% EnsemblesOverTime.PostInsight.pW2.S_Rule_sem    = S_HiPerfRule_beta_SEMs;
% EnsemblesOverTime.PostInsight.pW2.S_Image_mean  = S_HiPerfImage_beta_means;
% EnsemblesOverTime.PostInsight.pW2.S_Image_sem   = S_HiPerfImage_beta_SEMs;
% EnsemblesOverTime.PostInsight.pW2.S_Action_mean = S_HiPerfAction_beta_means;
% EnsemblesOverTime.PostInsight.pW2.S_Action_sem  = S_HiPerfAction_beta_SEMs;
           
end



if plotFigs
figure;
hold on
rp = plot(BeforeRULE_DXDT,'LineWidth',2,'color',CT(1,:));
ip =plot(BeforeIMAGE_DXDT,'LineWidth',2,'color',CT(2,:));

xlim([200 2400]);
ylim([0 .6]);
plot([200 200],[min(ylim) max(ylim)],'LineWidth',1,'color','k');
plot([700 700],[min(ylim) max(ylim)],'LineWidth',1,'color','k');
plot([1200 1200],[min(ylim) max(ylim)],'LineWidth',1,'color','k');
plot([2200 2200],[min(ylim) max(ylim)],'LineWidth',1,'color','k');
ylabel('ENSEMBLE FRACTION');
xlabel('Time (ms)');
legend([rp, ip],'RULE', 'IMAGE','location','northwest');
hold off
end % of plotting




end % of function