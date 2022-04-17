function [AUC_x_model_results,SelectivityTable] = CalculateAUCxQ_v01(SelectivityTable,epoch,DATADIR)
AUC_x_model_results= struct;





   CT =cbrewer('qual', 'Set1', 9);   
   SAME_c  = 2;
   DIFF_c  = 1; 
   P_c = 1;
   


    binAUC              = [];
    ME_difference_bin   = [];
    diffME_bin          = [];
    sameME_bin          = [];
    bin_PercentCorr     = [];
    binInsights         = [];
    binFRs              = [];
    binBlockChanges     = [];
    
    neuronPreferredRule = {};
    
    tmpQstates=[];
    tmpQxAUC=[];
    
    
for unit_ix = 1:numel(SelectivityTable.neuronName)  
         thisUnitName =  SelectivityTable.neuronName(unit_ix);

    
% for unit_ix = 1:numel(SelectivityTable.(epoch{1}).neuronName)
%     thisUnitName =  SelectivityTable.(epoch{1}).neuronName(unit_ix);

    % now load the data from that unit
    thisUnitData=[];
    thisUnitData = load([DATADIR thisUnitName{1} '.mat']);
    thisUnitData = thisUnitData.thisUnitData;
    
    SelectivePeriod = thisUnitData.(epoch{1}).AssessedRuleSelectiveEpoch; 
    SelectivePeriodFR = nanmean(thisUnitData.(epoch{1}).normalizedFRs(:,SelectivePeriod),2);
    neuronPreferredRule(unit_ix) = thisUnitData.(epoch{1}).preferredRule; 
    
    
    % get the model estimates
%     SAME_ModelEstimates=thisUnitData.(epoch{1}).trialFeatures.SameEstimates;
%     DIFF_ModelEstimates=thisUnitData.(epoch{1}).trialFeatures.DiffEstimates;
%     ModelDifferences = abs(SAME_ModelEstimates - DIFF_ModelEstimates);
%     % normalize the model difference
%     ModelDifferences = (ModelDifferences - min(ModelDifferences)) / (max(ModelDifferences) - min(ModelDifferences));
%     ModelDifferences = (2*ModelDifferences)-1;

    Qsame=thisUnitData.(epoch{1}).trialFeatures.Qsame;
    Qdiff=thisUnitData.(epoch{1}).trialFeatures.Qdiff; 
    
     Qsame = (Qsame - min(Qsame)) / (max(Qsame) - min(Qsame)); Qsame = (2*Qsame)-1;
     Qdiff = (Qdiff - min(Qdiff)) / (max(Qdiff) - min(Qdiff)); Qdiff = (2*Qdiff)-1;
     ModelDifferences = abs(Qsame - Qdiff);

%     modelDiffBins = thisUnitData.(epoch{1}).trialFeatures.ModelBins;
    modelDiffBins = discretize(ModelDifferences,10);
    BIN_IDs = unique(modelDiffBins);
    
    % now go through each bin and calculate stuff 
    tmp_AUC_bins          = NaN(1,10);
    tmpME_difference_bins = NaN(1,10);

    SameIX = contains(thisUnitData.(epoch{1}).trialFeatures.rule,'same');
   
%--------------------------------------------------------------
% go through the bins
%--------------------------------------------------------------
  
    for bin_idx = 1:numel(BIN_IDs)
      thisBin = BIN_IDs(bin_idx);
      % find data from this bin
        dataInBin_idx = modelDiffBins == thisBin;        
%--------------------------------------------------------------

      FiringRatesInBin = SelectivePeriodFR(dataInBin_idx);
      RulesInBin       = SameIX(dataInBin_idx);      
      savePos = thisBin+1;
      if numel(unique(RulesInBin)) > 1
      [~,~,~,AUC] = perfcurve(RulesInBin,FiringRatesInBin,1);       
      % save the AUC vals
      tmp_AUC_bins(1,bin_idx)          = AUC;
      tmpME_difference_bins(1,bin_idx) = nanmean(ModelDifferences(dataInBin_idx));

      
      else
           tmp_AUC_bins(1,bin_idx)          = NaN;
           tmpME_difference_bins(1,bin_idx) = NaN;

      end
    end % of going through each bin
       binAUC(unit_ix,:)            = tmp_AUC_bins;
       ME_difference_bin(unit_ix,:) = tmpME_difference_bins;

      % save some results of this neuron
      SelectivityTable.Qstates{unit_ix} = tmpME_difference_bins;
      SelectivityTable.QxAUC{unit_ix}   = tmp_AUC_bins;
      
       
end % of going through each neuron



return