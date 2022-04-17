function [FR_Change,BlockLens,BlockQdiffs,BlockFRs,BlockAha,BlockRules,upperCI] = CollectFRxBL_v01(SelectivityTable,epoch,specificNeurons,DATADIR)
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

FR_Change=[];
BlockLens=[];

   specificNeurons = {'Z191005-sig009h'};


   % standardize the font sizes
   lbl_fntSz = 15;
   ax_FntSz = 13;
   
   % standardize the line widths
   LW = 3;
   
   % standardize axis line width
   ax_LW = 1;
 
   
%  S_tbl = SelectivityTable.(epoch{1});
 S_tbl = SelectivityTable;


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
       
%----------------------------------------------------------------------        

  [FR_Change,BlockLens,BlockQdiffs,BlockFRs,BlockAha,BlockRules,upperCI]  = getBehavioralTransitionMoment_v04(thisUnitData);

  
  
      s_ix= contains(BlockRules,'same');
      
         BLxFR_mdl = fitlm(BlockLens,FR_Change);
         BL_b = BLxFR_mdl.Coefficients.Estimate(2);
         BL_int = BLxFR_mdl.Coefficients.Estimate(1);
         

%    BL_fig = figure;
%    set(BL_fig, 'Position', [100 100 350 350]);
%    set(gcf,'renderer','Painters');
%   hold on
%   plot(BlockLens(s_ix),FR_Change(s_ix),'.','color',CT(SAME_c,:),'LineWidth',3,...
%                 'MarkerFaceColor',CT(SAME_c,:),'MarkerEdgeColor',CT(SAME_c,:),'MarkerSize',35);
%   plot(BlockLens(~s_ix),FR_Change(~s_ix),'.','color',CT(DIFF_c,:),'LineWidth',3,...
%                 'MarkerFaceColor',CT(DIFF_c,:),'MarkerEdgeColor',CT(DIFF_c,:),'MarkerSize',35);
%    
%    plot([min(xlim) max(xlim)],[(min(xlim)*BL_b)+BL_int (max(xlim)*BL_b)+BL_int],'k','LineWidth',2);
%    ylim([0 30]);
%    xlabel('Block Length','FontSize',14);
%    ylabel('| \Delta Firing Rate (Hz) |','FontSize',14);  
%    
%     ax = gca;
%     ax.FontSize = 13;
%     ax.LineWidth = 1; 
%     
%     legend({'Switch to Same','Switch to Diff'},'FontSize',11);
%    
%    hold off
%   


end % of cycling through the units
end % of function


