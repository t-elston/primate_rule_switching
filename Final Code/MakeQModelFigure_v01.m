function [xxw] = MakeQModelFigure_v01(SelectivityTable,epoch,specificNeurons,behavioral_data,DATADIR)
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

g_ix = contains(behavioral_data.FileName,'G');
s_ix = contains(behavioral_data.rule,'same');
ModelBins = behavioral_data.ModelBins;
outcomes = double(contains(behavioral_data.outcome,'correct'));



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
PopQxAUC   = cell2mat(S_tbl.QxAUC);


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
    
    % get the behavioral data for the entire session the neuron was record
    % during
    SessionName = ThisUnitName{1:7};
    SessionName = SessionName(1:7);
    Session_ix = contains(behavioral_data.FileName,SessionName);
    SessionData = behavioral_data(Session_ix,:);
    Qsame = SessionData.Qsame;
    Qdiff = SessionData.Qdiff;
    
%     Qsame = (Qsame - min(Qsame)) / (max(Qsame) - min(Qsame));
%     Qsame = (2*Qsame)-1;
%     
%     Qdiff = (Qdiff - min(Qdiff)) / (max(Qdiff) - min(Qdiff));
%     Qdiff = (2*Qdiff)-1;
    
    
    
%----------------------------------------------------------------------   
SameIX = contains(SessionData.rule,'same');
DiffIX = contains(SessionData.rule,'diff');

HitIX  = contains(SessionData.outcome,'correct');
MissIX = contains(SessionData.outcome,'error');

SameChoices = double((SameIX & HitIX) | (DiffIX & MissIX)); SameChoices(SameChoices==0) = NaN;
DiffChoices = double((DiffIX & HitIX) | (SameIX & MissIX)); DiffChoices(DiffChoices==0) = NaN;

SameIX = double(SameIX); SameIX(SameIX==0)=NaN;
DiffIX = double(DiffIX); DiffIX(DiffIX==0)=NaN;

% make sample diagram of switching
ExFig = figure;
set(ExFig, 'Position', [100 100 700 200]);   
hold on
ylim([0 10]);
plot(SessionData.cumSum,'k','LineWidth',2);
plot(SameChoices*5,'.','MarkerSize',20,'color',CT2(Scol,:));
plot(DiffChoices*3,'.','MarkerSize',20,'color',CT2(Dcol,:));

plot(SameIX*9,'LineWidth',2,'color',CT2(Scol,:));
plot(DiffIX*9.5,'LineWidth',2,'color',CT2(Dcol,:));
yticks([0:2:8]);

ylabel('Hits out of 10');
xlim([140 260]);
xlabel('Trial Number');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       make figure and axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  QFig = figure;
  set(QFig, 'Position', [100 100 600 700]);   
  ExSession_ax     = axes('Position',[.1  .72 .8 .15]);
  QxPC_ax          = axes('Position',[.1  .4  .2  .15]);
  UnitQxAUC        = axes('Position',[.4  .4  .2  .15]);
  PopQxAUC_ax      = axes('Position',[.7  .4  .2  .15]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
    
%-----------------------------------------------------------------    
% Example Session 
axes(ExSession_ax);
hold on
plot(SessionData.cumSum,'k','LineWidth',2);
set(gca,'ycolor','k');
ylim([1 8]);
ylabel('Hits out of 10');

yyaxis right
plot(Qsame,'LineWidth',2,'color',CT2(Scol,:),'LineStyle','-');
plot(Qdiff,'LineWidth',2,'color',CT2(Dcol,:),'LineStyle','-');
set(gca,'ycolor','k');
ylabel('Qstate');
xlim([1 360]);
xlabel('Trial Number');
legend({'Real Behavior','Qsame','Qdiff'});
legend boxoff
 
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

    
%-----------------------------------------------------------------    
% Qstate x percent correct
axes(QxPC_ax);
hold on
G_Smeans = grpstats(outcomes(g_ix & s_ix),ModelBins(g_ix & s_ix));
G_Dmeans = grpstats(outcomes(g_ix & ~s_ix),ModelBins(g_ix & ~s_ix));

Z_Smeans = grpstats(outcomes(~g_ix & s_ix),ModelBins(~g_ix & s_ix));
Z_Dmeans = grpstats(outcomes(~g_ix & ~s_ix),ModelBins(~g_ix & ~s_ix));

plot(smooth(Z_Smeans),'LineWidth',3,'color',CT(SAME_c,:));
plot(smooth(Z_Dmeans),'LineWidth',3,'color',CT(DIFF_c,:));
plot(smooth(G_Smeans),'LineWidth',3,'color',CT(SAME_l_c,:));
plot(smooth(G_Dmeans),'LineWidth',3,'color',CT(DIFF_l_c,:));
lme_tbl = table(ModelBins,g_ix,s_ix,outcomes);
full_mdl = fitglme(lme_tbl,'outcomes ~ 1 + ModelBins*s_ix + (1|g_ix)','Distribution','binomial');
xlim([1 10]);
xticks([ 1 5 10]);
xlabel('\Delta Q Decile');
ylabel('p(Correct)');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

 
%-----------------------------------------
axes(UnitQxAUC);
hold on
if contains(S_tbl.preferredRule,'same')
    Ucol = CT2(Scol,:);
else
      Ucol = CT2(Dcol,:);
end
unitQxAUC = S_tbl.QxAUC{u_ix};
unit_mdl = fitlm([1:numel(S_tbl.CSxAUC{u_ix})],S_tbl.CSxAUC{u_ix});
unit_b = unit_mdl.Coefficients.Estimate(2);
unit_int = unit_mdl.Coefficients.Estimate(1);
plot(unitQxAUC,'.','MarkerSize',28,'color',Ucol);
plot(xlim,xlim*unit_b + unit_int,'k','LineWidth',1.5);
xlim([1 10]);
xticks([ 1 5 10]);
ylabel('Unit AUC');
xlabel('\Delta Q Decile');
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');
% title('Unit AUC');
hold off
 
%-----------------------------------------
 axes(PopQxAUC_ax);
 hold on
 SameQxAUCmean = nanmean(PopQxAUC(SameUnits,:));
 SameQxAUCsem = nanstd(PopQxAUC(SameUnits,:)) / sqrt(sum(SameUnits));
 
 DiffQxAUCmean = nanmean(PopQxAUC(~SameUnits,:));
 DiffQxAUCsem = nanstd(PopQxAUC(~SameUnits,:)) / sqrt(sum(~SameUnits));
 
 SameMdl = fitlm([1:10],SameQxAUCmean);
 S_b   = SameMdl.Coefficients.Estimate(2);
 S_int = SameMdl.Coefficients.Estimate(1);
 DiffMdl = fitlm([1:10],DiffQxAUCmean);
 D_b   = DiffMdl.Coefficients.Estimate(2);
 D_int = DiffMdl.Coefficients.Estimate(1);

 errorbar(SameQxAUCmean,SameQxAUCsem,'.','MarkerSize',28,'MarkerEdgeColor',CT2(Scol,:),'MarkerFaceColor',CT2(Scol,:),'color',CT2(Scol,:),'CapSize',0);
 errorbar(DiffQxAUCmean,DiffQxAUCsem,'.','MarkerSize',28,'MarkerEdgeColor',CT2(Dcol,:),'MarkerFaceColor',CT2(Dcol,:),'color',CT2(Dcol,:),'CapSize',0);
 x=[1 10];
 plot(x,x*S_b + S_int,'color',CT2(Scol,:),'LineWidth',2);
 plot(x,x*D_b + D_int,'color',CT2(Dcol,:),'LineWidth',2);
xlim([1 10]);
xticks([ 1 5 10]);
 ylim([.3 .7]);
 yticks([.3 .5 .7]);
 ylabel('Pop. AUC');
xlabel('\Delta Q Decile');

set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');
 FullMdl = fitlm([[1:10]';[1:10]'],[SameQxAUCmean'; 1 - DiffQxAUCmean']);
 
 hold off

end % of cycling through the units
end


