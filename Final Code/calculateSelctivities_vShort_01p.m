function [tmp_ST,tmp_spikeTables]  = calculateSelctivities_vShort_01p(tmp_spikeTables)
tmp_ST=table;
thisNeuronName = tmp_spikeTables.NeuronName;
% PreEureka_AUC = NaN;
% PostEureka_AUC = NaN;
% postXpriorHedgeGXBlockLen_r = NaN;
% SAMEInsight_mean = NaN;
% DIFFInsight_mean = NaN;

   rule_map1 = [ 
                 57 106 177  ;
                 218 124 48  ;
                 188 80  144 ;
                 62 150 81  ;
                 83 81 84   ;
                 ] / 255;              
   SAME_c  = 1;
   DIFF_c  = 5;  
   im1_c = 2;
   im2_c = 3;
   im3_c = 4;   
   color_table.same = rule_map1(SAME_c,:);
   color_table.diff = rule_map1(DIFF_c,:);
   color_table.im1 = rule_map1(im1_c,:);
   color_table.im2 = rule_map1(im2_c,:);
   color_table.im3 = rule_map1(im3_c,:);
   
   
   analysisWindowEnd = numel(tmp_spikeTables.rasters(1,:));

% use only the correct, 'post-eureka' trials for the feature classification
trialFeatures = tmp_spikeTables.trialFeatures;

   % use only the post-Eureka trials for the selectivity classification     
    postEureka_idx                = contains(trialFeatures.rel2Eureka,'TenAfterEureka');
    preEureka_idx                 = contains(trialFeatures.rel2Eureka,'TenBeforeEureka');
    allSame_idx                   = contains(trialFeatures.rule,'same');
    allDiff_idx                   = contains(trialFeatures.rule,'diff');
    correct_idx                   = contains(trialFeatures.outcome,'correct');    
    
  
    % get the firing rate data
    REG_FRs = tmp_spikeTables.smoothedFRs(correct_idx,:);
nrmlREG_FRs = tmp_spikeTables.normalizedFRs(correct_idx,:);   
    REG_Rasters = tmp_spikeTables.rasters(correct_idx,:);
    
    SampleFRs = mean(REG_FRs(:,701:1200),2);
    Delay1FRs = mean(REG_FRs(:,1201:1700),2);
    Delay2FRs = mean(REG_FRs(:,1701:2200),2);
               
%---------------------------------------------------------------------------    
% make the factor arrays for the regression   
    ruleFactor         = (trialFeatures.rule(correct_idx));
    sampleIDFactor     = (trialFeatures.sampleID(correct_idx));
    choiceDirFactor    = (trialFeatures.choiceDir(correct_idx));
    
    allFRs = [SampleFRs,Delay1FRs,Delay2FRs];

    % do anova
    
    [Sp,Stbl,Sstats] = anovan(allFRs(:,1),{ruleFactor sampleIDFactor},'varnames',{'rule','image'},'display','off');
    [D1p,D1tbl,D1stats] = anovan(allFRs(:,2),{ruleFactor sampleIDFactor},'varnames',{'rule','image'},'display','off');
    [D2p,D2tbl,D2stats] = anovan(allFRs(:,3),{ruleFactor sampleIDFactor},'varnames',{'rule','image'},'display','off');

    % calculate effect sizes
     [Sw2,~] = calculatePartialW2_v01(Stbl,numel(SampleFRs));
     [D1w2,~] = calculatePartialW2_v01(D1tbl,numel(SampleFRs));
     [D2w2,~] = calculatePartialW2_v01(D2tbl,numel(SampleFRs));
     
    allImageP = [Sp(2),D1p(2),D2p(2)];
    allpW2    = [Sw2(2),D1w2(2),D2w2(2)];
    
    %************* check if the unit was image selective
     if any(allImageP < .05)
         [~,epoch2Use] = min(allImageP);   
    tmp_ST.neuronName = thisNeuronName;
    tmp_ST.SelectiveEpoch = epoch2Use;
    
    SelectiveFRs = allFRs(:,epoch2Use);
    
    % which image did it prefer?
    imFRmeans = grpstats(SelectiveFRs,sampleIDFactor);
    [~,prefImage ] =max(imFRmeans);
    tmp_ST.preferredImage = prefImage; 
      
    % what's this neuron's rule-related AUC?
    [~,~,~,AUC] = perfcurve(ruleFactor,SelectiveFRs,'same');
    tmp_ST.ruleAUC = AUC;

    % what's this unit's behavioral trans look like?
       [preEurekaFR,postEurekaFR,priorBlockFRs, Aha_trialNums,transitionRules, blockLens,h_g,Shuffled_Corrs] = ...
            getBehavioralTransitionMoment_v03(SelectiveFRs,trialFeatures(correct_idx,:));
        FR_Change = abs(postEurekaFR-priorBlockFRs)'; 
        tmp_ST.Corr = corr(h_g',blockLens');
        tmp_ST.ShuffledCorr{1} = Shuffled_Corrs;
        
        % how is this neuron's selectivity effected by reinforcement?
        [CSxpW2] = relateCSandImageSelectivity_v01(SelectiveFRs,trialFeatures(correct_idx,:));   
        tmp_ST.CSxpW2 = CSxpW2;
    xx=[];     
     end % of assessing image selectivity
 


return