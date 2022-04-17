function [CS_x_model_results,SelectivityTable] = CalculateAUCxCS_v01(SelectivityTable,epoch,DATADIR)
CS_x_model_results= struct;

    binAUC              = [];
    neuronPreferredRule = {};

    for unit_ix = 1:numel(SelectivityTable.neuronName)
    
    thisUnitName =  SelectivityTable.neuronName(unit_ix);
    
% for unit_ix = 1:numel(SelectivityTable.(epoch{1}).neuronName)
%     
%     thisUnitName =  SelectivityTable.(epoch{1}).neuronName(unit_ix);
    % now load the data from that unit
    thisUnitData=[];
    thisUnitData = load([DATADIR thisUnitName{1} '.mat']);
    thisUnitData = thisUnitData.thisUnitData;
    
    SelectivePeriod = thisUnitData.(epoch{1}).AssessedRuleSelectiveEpoch; 
    SelectivePeriodFR = nanmean(thisUnitData.(epoch{1}).normalizedFRs(:,SelectivePeriod),2);
    neuronPreferredRule(unit_ix) = thisUnitData.(epoch{1}).preferredRule; 

    
    cumSums = thisUnitData.(epoch{1}).trialFeatures.cumSum;
    SameIX = contains(thisUnitData.(epoch{1}).trialFeatures.rule,'same');


  


     BIN_IDs = unique(cumSums); BIN_IDs = [2:9]; % ensures we look at cumSums 1:8
  
    
    % now go through each bin and calculate stuff 
    tmp_AUC_bins          = NaN(1,numel(BIN_IDs));
    
    for bin_idx = 1:numel(BIN_IDs)
      thisBin = BIN_IDs(bin_idx);
      % find data from this bin
        dataInBin_idx = cumSums == thisBin;        

%--------------------------------------------------------------

      FiringRatesInBin = SelectivePeriodFR(dataInBin_idx);
      RulesInBin       = SameIX(dataInBin_idx);
     
      
      savePos = thisBin+1;
      if numel(unique(RulesInBin)) > 1
      [~,~,~,AUC] = perfcurve(RulesInBin,FiringRatesInBin,1);       
      % save the AUC vals
      tmp_AUC_bins(1,bin_idx)          = AUC;
     
      
      else
           tmp_AUC_bins(1,bin_idx)          = NaN;

           
      end
    end % of going through each bin
       binAUC(unit_ix,:)            = tmp_AUC_bins;
 
       
       
       % save some results of this neuron
         SelectivityTable.CSxAUC{unit_ix} =  tmp_AUC_bins;

end % of going through each neuron


return