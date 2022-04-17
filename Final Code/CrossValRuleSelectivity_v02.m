function [TrainHP_AUC,TestHP_AUC,LowPerf_AUC,WinStart] = CrossValRuleSelectivity_v02(DATADIR)


% read in the data (.mat files)
fileList = dir(fullfile(DATADIR, '*.mat'));
FileNames = {fileList.name};


% go through each file
nUnits = numel(FileNames);
nFolds = 100; 

% pre-allocate output
TrainHP_AUC = NaN(nFolds,nUnits);
TestHP_AUC  = NaN(nFolds,nUnits);
LowPerf_AUC = NaN(nFolds,nUnits);
WinStart    = NaN(nFolds,nUnits);

for u = 1:nUnits
    
  thisUnitData = load([FileNames{u}]); 
  thisUnitData = thisUnitData.thisUnitData.beforeChoice;
  unitName = thisUnitData.NeuronName;    
    
 trialFeatures = thisUnitData.trialFeatures;
 FiringRates   = thisUnitData.smoothedFRs;

 
 %---------------------------------------------------------------------------
 % start doing the split half over nFolds
 
 parfor f = 1:100
     [TrainHP_AUC(f,u),TestHP_AUC(f,u),LowPerf_AUC(f,u),WinStart(f,u)] = ProcessXvalInParallel_v01p(trialFeatures,FiringRates);

 end % of going through this fold

 
end % of cycling through files


SigUnits = ttest(TestHP_AUC,.5);

figure;
subplot(1,2,1)
histogram(nanmean(TestHP_AUC(:,logical(SigUnits))));
xlabel('AUROC in Held Out Hi Perf Trials');

subplot(1,2,2)
histogram(nanmean(LowPerf_AUC(:,logical(SigUnits))));
xlabel('AUROC in Low Perf Trials');




end % of function