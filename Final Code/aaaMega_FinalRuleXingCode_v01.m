
%*******************
% manually load behavioral_data and BlockData from the SummarizedData directory.
 
% where the neurons are - adjust this for your machine
DATADIR = 'C:\Users\Thomas Elston\Documents\MATLAB\Projects\Rule-Switching\Neurons\';

%    determine selectivity of neurons
onlyAssessSelective=0;
DO_PERM_REGS = 0; % hold off on permuted distributions at first
[SelectivityTable] = calculateSelectivities_v08(onlyAssessSelective,DO_PERM_REGS,'both',DATADIR);
[SelectivityTable] = calculateEpochMeanFRs_v02(SelectivityTable);

[TrainHP_AUC,TestHP_AUC,LowPerf_AUC,WinStart] = CrossValRuleSelectivity_v02(DATADIR);


% now look at the evolution of the task set in periods of high and low
% performance
plotFigs = 1;
[EnsemblesOverTime] = AssessTaskModelEvolution_v01(DO_PERM_REGS,'both',plotFigs,DATADIR);


% get the QxAUC and CSxAUC relationships
[AUC_x_model_results,SelectivityTable] = CalculateAUCxQ_v01(SelectivityTable,{'beforeChoice'},DATADIR);
[AUC_x_CS_results,SelectivityTable] = CalculateAUCxCS_v01(SelectivityTable,{'beforeChoice'},DATADIR);


%************** FIGURE 2 - behavior
[block_data] = assessBehavioralData_v01(behavioral_data);
[behavioral_data_for_plotting] = PlotBehavioralData_v03(block_data,behavioral_data);
[xt] = RTxCumSum_v03(behavioral_data);

% supplementary figure
[R_vals, p_vals] = MakeMotivationOverTime_v01(behavioral_data);


  specificNeurons = {'Z191005-sig009h'};
  [xxw] = plotSelectiveUnits_v04(SelectivityTable,{'beforeChoice'},specificNeurons,EnsemblesOverTime,DATADIR);
  AssessPopCSxAUC; % use this to formally assess CSxAUC and QxAUC (just change the field called in the selectivity table          
%------------------------------
% Fig 4 - Q learning
[xxw] = MakeQModelFigure_v01(SelectivityTable,{'beforeChoice'},specificNeurons,behavioral_data,DATADIR);
%------------------------------                                                          
 
%------------------------------
% Fig 5 - FRxBL
 [FR_Change,BlockLens,BlockQdiffs,BlockFRs,BlockAha,BlockRules,upperCI] = CollectFRxBL_v01(SelectivityTable,{'beforeChoice'},{},DATADIR);
 [TF] = SummarizeFRxBLWithExampleBlocks_v01(SelectivityTable,'both','Pre',FR_Change,BlockLens,BlockQdiffs,BlockFRs,BlockAha,BlockRules,upperCI);
%------------------------------  
  
  
%***************** FIG 6 - CONTROL ANALYSIS
% look at effects in image-encoding units
[ImageSelectivityTable] = calculateSelectivities_vShort_01('both',DATADIR);
 MakeImageControlFig_v01(ImageSelectivityTable);
 
%***************** FIG 7 - POPULATION ANALYSIS - not confident about this,
%                  so, I've left it out so we can build it together



