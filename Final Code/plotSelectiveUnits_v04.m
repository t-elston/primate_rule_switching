function [xxw] = plotSelectiveUnits_v04(SelectivityTable,epoch,specificNeurons,EnsemblesOverTime,DATADIR)
xxw=[];


% define color scheme
CT =cbrewer('qual', 'Paired', 12);
CT = [CT; [.4 .4 .4] ; [0 0 0]];
SAME_c   = 2;
SAME_l_c = 1;
DIFF_c   = 6;
DIFF_l_c = 5;
all_s_c  = 13;
max_s_c  = 14;
Insight_c  = 14;
PreInsight_c  = 13;

CT2 =cbrewer('qual', 'Set1', 9);
Scol = 2;
Dcol = 1;


   % standardize the font sizes
   lbl_fntSz = 15;
   ax_FntSz = 13;
   
   % standardize the line widths
   LW = 3;
   
   % standardize axis line width
   ax_LW = 1;
 
   
%  S_tbl = SelectivityTable.(epoch{1});
 S_tbl = SelectivityTable;
 SameUnits = contains(S_tbl.preferredRule,'same');
%-------------------------------------------------
% EXTRACT THE POPULATION MEASURES
Fractions = [EnsemblesOverTime.PreInsight.Fraction.Rule;EnsemblesOverTime.PostInsight.Fraction.Rule];
PopFraction = smooth(nanmean(Fractions));
PopCSxAUC   = cell2mat(S_tbl.CSxAUC);
PopAUC      = (S_tbl.allCorrAUC);
RectAUC = PopAUC;
RectAUC(~SameUnits) = 1-PopAUC(~SameUnits);
X = RectAUC < .5;


%-------------------------------------------------
% load and plot each cell
if ~isempty(specificNeurons)
    selectedNeurons = specificNeurons;
    % find those neurons in the selecitivity table
  theseNeurons = contains(S_tbl.neuronName,specificNeurons);
  S_tbl = S_tbl(theseNeurons,:);
end

numUnits = numel(S_tbl.neuronName);

for u_ix = 1:numUnits
    ThisUnitName = S_tbl.neuronName(u_ix);
    % load that unit's data
    thisUnitData=[];
    thisUnitData = load([DATADIR ThisUnitName{1} '.mat']);
    thisUnitData = thisUnitData.thisUnitData.(epoch{1});
    
    FiringRates = thisUnitData.rawFRs;
    Rasters     = thisUnitData.rasters;
    All_selective_moments =  double(thisUnitData.AllRuleSelectiveEpochs);
    All_selective_moments(All_selective_moments==0)=NaN;
    AssessedMoments =  thisUnitData.AssessedRuleSelectiveEpoch;
    nonSelectiveMoments = AssessedMoments==0;
    AssessedMoments_forPlotting = double(AssessedMoments);
    AssessedMoments_forPlotting(nonSelectiveMoments) = NaN;
    
    % now get some useful indices for plotting
    FeatureIndex = thisUnitData.trialFeatures;
    Hit_ix   =contains(FeatureIndex.outcome,'correct');
    Error_ix   =contains(FeatureIndex.outcome,'error');
    HighPerf_ix = contains(FeatureIndex.rel2Eureka,'TenAfterEureka');
    LowPerf_ix = contains(FeatureIndex.rel2Eureka,'TenBeforeEureka');
%     HighPerf_ix = FeatureIndex.cumSum > 4;
%     LowPerf_ix  = FeatureIndex.cumSum < 5;
    same_ix    = contains(FeatureIndex.rule,'same');
    diff_ix    = contains(FeatureIndex.rule,'diff');
    CS_ix = FeatureIndex.cumSum >= 6;
    
    grp_ix  = HighPerf_ix;
    grp2_ix = LowPerf_ix;
%----------------------------------------------------------------------        
    
s = 3; % amount of space between rules
HPsameRasters=Rasters(same_ix & grp_ix,:);
HPdiffRasters=Rasters(diff_ix & grp_ix,:);

LPsameRasters=Rasters(same_ix & grp2_ix,:);
LPdiffRasters=Rasters(diff_ix & grp2_ix,:);

num2keep = min([sum(same_ix & grp_ix) sum(diff_ix & grp_ix) sum(same_ix & grp2_ix) sum(diff_ix & grp2_ix)]);
HPsameRasters = HPsameRasters(1:num2keep,:);
HPdiffRasters = HPdiffRasters(1:num2keep,:);
LPsameRasters = LPsameRasters(1:num2keep,:);
LPdiffRasters = LPdiffRasters(1:num2keep,:);

 HPsameRasters=shufflerows(HPsameRasters);
 LPsameRasters=shufflerows(LPsameRasters);
 HPdiffRasters=shufflerows(HPdiffRasters);
 LPdiffRasters=shufflerows(LPdiffRasters);



R_ix = [ones(num2keep,1)*SAME_c ; NaN(s,1) ;...
        ones(num2keep,1)*SAME_l_c; NaN(s,1) ;...
        ones(num2keep,1)*DIFF_l_c ; NaN(s,1) ;...
        ones(num2keep,1)*DIFF_c; NaN(s,1)];
        
       
allRasters = [HPsameRasters; NaN(s,2700) ;...
              LPsameRasters ; NaN(s,2700) ;...
              LPdiffRasters; NaN(s,2700) ;...
              HPdiffRasters; NaN(s,2700)];


% do rasters according to number of hits


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       make figure and axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  UnitFig = figure;
  set(UnitFig, 'Position', [100 100 600 700]);   
  raster_ax     = axes('Position',[.1  .7  .3  .15]);
  PSTH_ax       = axes('Position',[.1  .55 .3  .15]);
  Fraction_ax   = axes('Position',[.1  .3  .3  .15]);
  
%   Brain_ax      = axes('Position',[.1  .82 .1  .1]);
  
%   AUChist_ax    = axes('Position',[.25  .35 .1  .1]); 
  
  UnitCSxAUC_ax = axes('Position',[.55  .55 .22  .15]); 
  PopCSxAUC_ax  = axes('Position',[.55  .3  .22  .15]);  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 set(gcf,'renderer','Painters'); 
% 
annotation('textbox',[.025 .77 .2 .2],'String',ThisUnitName,...
        'FitBoxToText','on','FontWeight','Bold','FontSize',12);
    
    
%-----------------------------------------------------------------    
% FRACTION 
axes(Fraction_ax);
hold on
plot(PopFraction,'color',CT2(4,:),'LineWidth',LW);
xlim([200 2200]);
ylim([0 .25]);
plot([700 700],[min(ylim) max(ylim)],'color','k','LineWidth',ax_LW,'LineStyle','-');
plot([1200 1200],[min(ylim) max(ylim)],'color','k','LineWidth',ax_LW,'LineStyle','-');
xticks([200 700 1200 1700 2200]);
xt = xticks;
xticklabels(xt - 200);
ylabel('Ensemble Fraction');
xlabel('Time from Fixation (ms)');  
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

    
%-----------------------------------------------------------------    
% RASTERS
axes(raster_ax);
hold on
for r = 1:numel(R_ix)

     if ~isnan(R_ix(r))
         if ~isempty(find(allRasters(r,:)))
           plot(find(allRasters(r,:)),r,'.','color',CT(R_ix(r),:),'MarkerSize',4);
         end
     end   
end
%       axis tight;
      xlim([200 2200]);
      plot([700 700],[min(ylim) max(ylim)],'color','k','LineWidth',ax_LW,'LineStyle','-');
      plot([1200 1200],[min(ylim) max(ylim)],'color','k','LineWidth',ax_LW,'LineStyle','-');
      xt = xticks;
      xticklabels(xt - 200);
       set(gca,'ydir','reverse');
      set(gca,'xtick',[]);
      set(gca,'Visible','off');
      hold off

%-----------------------------------------------------------------
%PSTHs
axes(PSTH_ax);
HPSameFRmean = nanmean(FiringRates(grp_ix & same_ix,:));
HPDiffFRmean = nanmean(FiringRates(grp_ix & diff_ix,:));
LPSameFRmean = nanmean(FiringRates(grp2_ix & same_ix,:));
LPDiffFRmean = nanmean(FiringRates(grp2_ix & diff_ix,:));
hold on

plot(smooth(HPSameFRmean),'LineWidth',LW,'color',CT(2,:));
plot(smooth(HPDiffFRmean),'LineWidth',LW,'color',CT(6,:));
plot(smooth(LPSameFRmean),'LineWidth',LW,'color',CT(1,:));
plot(smooth(LPDiffFRmean),'LineWidth',LW,'color',CT(5,:));
axis tight;

ylim([0 35]);
xlim([200 2200]);
% plot(All_selective_moments*.05*max(ylim) + min(ylim),'color','k','LineWidth',1);
plot(AssessedMoments_forPlotting*.05*max(ylim) + min(ylim),'color',CT(all_s_c,:),'LineWidth',4);

[PSTH_lgd,PSTH_lgd_props]=legend({'Same','Diff'},...
                               'FontSize',12, 'Location',[.04 .44 .08 .08]);
                           
                           
         PSTHLines=findobj(PSTH_lgd_props,'type','line');  % get the lines, not text
         set(PSTHLines,'linewidth',LW)            % set their width property
         legend boxoff

plot([700 700],[min(ylim) max(ylim)],'color','k','LineWidth',ax_LW,'LineStyle','-');
plot([1200 1200],[min(ylim) max(ylim)],'color','k','LineWidth',ax_LW,'LineStyle','-');
xticks([200 700 1200 1700 2200]);
xt = xticks;
xticklabels(xt - 200);
ylabel('Firing Rate (Hz)');

set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');
xx=[];
hold off


%-----------------------------------------
axes(UnitCSxAUC_ax);
hold on
if contains(S_tbl.preferredRule,'same')
    Ucol = CT2(Scol,:);
else
      Ucol = CT2(Dcol,:);
end
% Ucol = CT2(2,:);
unitCSxAUC = S_tbl.CSxAUC{u_ix};
unit_mdl = fitlm([1:numel(S_tbl.CSxAUC{u_ix})],S_tbl.CSxAUC{u_ix});
unit_b = unit_mdl.Coefficients.Estimate(2);
unit_int = unit_mdl.Coefficients.Estimate(1);
plot(unitCSxAUC,'.','MarkerSize',25,'color',Ucol);
xlim([.5 8.5]);
ylim([0 .85]);
plot(xlim,xlim*unit_b + unit_int,'k','LineWidth',1.5);
ylabel('Unit AUC');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');
hold off
 
%-----------------------------------------
 axes(PopCSxAUC_ax);
 hold on
 SameCSxAUCmean = nanmean(PopCSxAUC(SameUnits,:));
 SameCSxAUCsem = nanstd(PopCSxAUC(SameUnits,:)) / sqrt(sum(SameUnits));
 
 DiffCSxAUCmean = nanmean(PopCSxAUC(~SameUnits,:));
 DiffCSxAUCsem = nanstd(PopCSxAUC(~SameUnits,:)) / sqrt(sum(~SameUnits));
 
 SameMdl = fitlm([1:numel(SameCSxAUCmean)],SameCSxAUCmean);
 S_b   = SameMdl.Coefficients.Estimate(2);
 S_int = SameMdl.Coefficients.Estimate(1);
 DiffMdl = fitlm([1:numel(DiffCSxAUCmean)],DiffCSxAUCmean);
 D_b   = DiffMdl.Coefficients.Estimate(2);
 D_int = DiffMdl.Coefficients.Estimate(1);

 errorbar(SameCSxAUCmean,SameCSxAUCsem,'.','LineWidth',LW,'MarkerSize',18,'MarkerEdgeColor',CT2(2,:),'MarkerFaceColor',CT2(2,:),'CapSize',0,'color',CT2(2,:));
 errorbar(DiffCSxAUCmean,DiffCSxAUCsem,'.','LineWidth',LW,'MarkerSize',18,'MarkerEdgeColor',CT2(1,:),'MarkerFaceColor',CT2(1,:),'CapSize',0,'color',CT2(1,:));
 x=[1 10];
 plot(x,x*S_b + S_int,'color',CT2(2,:),'LineWidth',2);
 plot(x,x*D_b + D_int,'color',CT2(1,:),'LineWidth',2);
xlim([.5 8.5]);
xlabel('Recent Hits out of 10');
ylabel('Pop. AUC');
 set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

 hold off
 
 
% save the candidate neurons
% SaveFileName = [ThisUnitName{1} '.jpeg'];
% saveas(UnitFig,SaveFileName);

    

end % of cycling through the units
end


