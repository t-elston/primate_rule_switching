function [TrainHP_AUC,TestHP_AUC,LowPerf_AUC,WinStart] = ProcessXvalInParallel_v01p(trialFeatures,FiringRates)

 % use only the last 10 in a block trials for the rule classification
 HiPerf_idx    = contains(trialFeatures.rel2Eureka,'TenAfterEureka');
 LowPerf_idx   = contains(trialFeatures.rel2Eureka,'TenBeforeEureka');  % 10 trials immediately preceeding the high perf ones

 % split-half partition the data for this fold
 HP_ixs = find(HiPerf_idx); 
 randomIX = randperm(numel(HP_ixs));
 
 TrainIX = randomIX(1:floor(numel(randomIX)*.5));  TrainHP_IX = HP_ixs(TrainIX);
 TestIX  = randomIX(ceil(numel(randomIX)*.5):end); TestHP_IX  = HP_ixs(TestIX);
 
    
 % get the firing rate data
   TRAIN_HP_FRs = FiringRates(TrainHP_IX,:);
   TEST_HP_FRs  = FiringRates(TestHP_IX,:);
   LP_FRs       = FiringRates(LowPerf_idx,:);
   
  
   % collect the relevant features for the anova / pw2 
  TRAIN_HiPerfFactors = {trialFeatures.rule(TrainHP_IX),trialFeatures.sampleID(TrainHP_IX),trialFeatures.choiceDir(TrainHP_IX)}; 
  TEST_HiPerfFactors = {trialFeatures.rule(TestHP_IX),trialFeatures.sampleID(TestHP_IX),trialFeatures.choiceDir(TestHP_IX)}; 
  LowPerfFactors = {trialFeatures.rule(LowPerf_idx),trialFeatures.sampleID(LowPerf_idx),trialFeatures.choiceDir(LowPerf_idx)}; 

    
    
  % speed things up... bigger step size for sliding window
            numTimeSteps = numel(TRAIN_HP_FRs(1,:));
            wLen = 201;
            centerDist = ceil(wLen/2)-1;
            analyzedSteps = numTimeSteps;
            stepSize = 20;
          
            numSaveBins = numTimeSteps/stepSize;
  
    % pre-allocate the data for quick parallel processing
    bin_ctr=0;
    LowPerf_FRs={};
    TRAIN_HiPerf_FRs={};
    TEST_HiPerf_FRs={};
   
   for wStart = 1:stepSize:analyzedSteps 
       bin_ctr=bin_ctr+1;
        % figure out stuff about the window dimensions               
        if (wStart + wLen) <= numTimeSteps
            wEnd = wStart + wLen-1;
        else
            wEnd = numTimeSteps;
        end  
   LowPerf_FRs{bin_ctr}          = nanmean(LP_FRs(:,wStart:wEnd),2);   
   TRAIN_HiPerf_FRs{bin_ctr}     = nanmean(TRAIN_HP_FRs(:,wStart:wEnd),2);    
   TEST_HiPerf_FRs{bin_ctr}     = nanmean(TEST_HP_FRs(:,wStart:wEnd),2);     

   end
   
% now do the selectivity classification in parallel
parfor bin_ix = 1:numSaveBins
               
[HP_pvals(:,bin_ix), HP_pW2(:,bin_ix),~] = doClassification_v01(cell2mat(TRAIN_HiPerf_FRs(bin_ix)), TRAIN_HiPerfFactors, 'anova','noShuffle');   
   
end % of cycling through time steps  

% find the largest 300ms window of the rule pW2 (first row of HP_pW2)
% within the valid pre-choice period
validPeriod = zeros(size(LowPerf_FRs)); validPeriod(200/stepSize : 2200/stepSize) = 1;
validPeriod = logical(validPeriod);
[~,PeakBinCenter] = max(movmean(HP_pW2(1,validPeriod),[8 8]));

% get the indices of that window's beginning and end
peakWstart = PeakBinCenter + 8;  % take into account the index constraint by the validPeriod above
peakWend   = PeakBinCenter + 16;

% check and correct for any negative window starts (very early possitible 

% get mean firing rates of that window
TRAIN_HP_winFRs = TRAIN_HiPerf_FRs{peakWstart:peakWend};
TEST_HP_winFRs  = TEST_HiPerf_FRs{peakWstart:peakWend};
LP_winFRs       = LowPerf_FRs{peakWstart:peakWend};

% compute the AUC values
[~,~,~,TrainHP_AUC] = perfcurve(TRAIN_HiPerfFactors{1},TRAIN_HP_winFRs,'same');
[~,~,~,TestHP_AUC] = perfcurve(TEST_HiPerfFactors{1},TEST_HP_winFRs,'same');
[~,~,~,LowPerf_AUC] = perfcurve(LowPerfFactors{1},LP_winFRs,'same');

% store the window start location
WinStart = peakWstart;


end % of function