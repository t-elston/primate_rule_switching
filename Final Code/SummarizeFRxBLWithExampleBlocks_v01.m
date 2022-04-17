function [TF] = SummarizeFRxBLWithExampleBlocks_v01(SelectivityTable,monkey, epoch,FR_Change,BlockLens,BlockQdiffs,BlockFRs,BlockAha,BlockRules,upperCI)
TF = 0;

% % define plotting color scheme  
   CT =cbrewer('qual', 'Set1', 9);   
   CT2 =cbrewer('qual', 'Accent', 8); 
   SAME_c  = 2;
   DIFF_c  = 1; 
   CDF_c = 1;
   
 


   % standardize the font sizes
   lbl_fntSz = 13;
   ax_fntSz = 12;
   
   % standardize the line widths
   LW = 2.5;   
   % standardize axis line width
   ax_LW = 1;
   
%--------------------------------------------------------------------------
%       Determine which monkey and epoch to use
%--------------------------------------------------------------------------
units2use=[];
units2use = SelectivityTable;
% switch epoch
%     
%     case 'Pre'
%         units2use = SelectivityTable.beforeChoice;
%         
%         
%     case 'Post'
%         units2use = SelectivityTable.afterChoice;
%         
%     case 'all'
%         units2use = [SelectivityTable.beforeChoice;SelectivityTable.afterChoice];
%     
% end % of determining which epoch to use

Z_files = contains(units2use.neuronName,'Z');
G_files = contains(units2use.neuronName,'G');

UnitsForAnalysis=[];
switch monkey
    
    case 'Ziggy'
        UnitsForAnalysis = units2use(Z_files);
        
    case 'Grover'
        UnitsForAnalysis = units2use(G_files);
    case 'both'
       UnitsForAnalysis = units2use;
end % of switch monkey
%--------------------------------------------------------------------------


%---------------------------------------
% CORRELATION CDF 
%---------------------------------------
sigfigs = 2;
nboots = 1000;

corrs = UnitsForAnalysis.rawCorrVal;
B_neg = sum(corrs<0);
B_pos = sum(corrs>0);
numB =  sum(~isnan(corrs));
[chi2_tbl,chi2stat,chi2_pval] = chiSquareWithFrequencies_v01(B_neg,numB,B_pos,numB);
ShuffledCorrs = cell2mat(UnitsForAnalysis.ShuffledCorrs);
[ks_h,ks_p]  = kstest(corrs*3);
 [ks_p] = MakeP_string_v01(ks_p);
 [SR_pval] = signrank(corrs,0,'tail','left');
 [SR_pval] = MakeP_string_v01(SR_pval);

[ecdf_f1, ecdf_x1,flo,fhi] = ecdf(corrs);
CIs = abs(flo-fhi);

[~,median_ix] = min(abs(ecdf_f1-.5));
 slope_median = ecdf_x1(median_ix);


  ecdf_x1 = [ -1 ; ecdf_x1; 1];
  ecdf_f1 = [ .0   ; ecdf_f1; 1];

 % make / plot a normal distribution
 pd = makedist('Normal');
 stdnrml_x   = [-3:.1:3];
 stdnrml_cdf = cdf(pd,stdnrml_x);
 stdnrml_x = stdnrml_x/3;
                       
[integral_pval] = IntegralEffectSize_v01(nboots,ecdf_x1,ecdf_f1);
 
%[p_string] = MakeP_string_v01(pval) 
summary_text{1,1} = ['kstest ' ks_p];
summary_text{2,1} = ['signrank ' SR_pval];


% let's collect the individual x-axis values so we can display the true
% densities
corr_colors=[];
corr_y=[];
 for b_ix = 1:numel(corrs)
     switch UnitsForAnalysis.preferredRule{b_ix}
         case 'same'
             corr_colors(b_ix,:) = CT(SAME_c,:);
             corr_y(b_ix) = .1;
             
         case 'diff'
             corr_colors(b_ix,:) = CT(DIFF_c,:);
             corr_y(b_ix) = .15;
     end     
 end

     
%---------------------------------------------------------
% let's plot!
FRxBL_fig = figure;
set(FRxBL_fig, 'Position', [100 100 650 750]); set(gcf,'renderer','Painters');
b1_ax =   axes('Position',[.1  .7 .25 .2]);
b2_ax =   axes('Position',[.1  .4 .25 .2]);
b3_ax =   axes('Position',[.1  .1 .25 .2]);
FrxBL_ax =axes('Position',[.6  .7 .25 .2]);
CDF_ax   =axes('Position',[.6  .4 .25 .2]);
Perm_ax  =axes('Position',[.6  .1 .25 .2]);

MkerSz = 15;


Blocks2Use = [4 5 3]; % specify the blocks to use in the order you want to use them

axes(b1_ax);
hold on
plot(BlockQdiffs{4},'LineWidth',LW,'color','k');
plot(xlim,[upperCI upperCI],'color',CT(9,:),'LineWidth',LW/2,'LineStyle','-.');
plot([BlockAha(4) BlockAha(4)],[upperCI upperCI],'+','color',CT(1,:),'LineWidth',LW/1,'MarkerSize',MkerSz,'HandleVisibility','off');
ylabel('| Qsame - Qdiff |','FontSize',lbl_fntSz);
ylim([0 1]);
axis tight;
yyaxis right
yticks([.2 , .4 , .6 ,.8]);
plot((BlockFRs{4}),'LineWidth',LW,'color',CT2(5,:));
ylabel('Firing Rate (Hz)','FontSize',lbl_fntSz);

ylim([0 50]);
yticks([0 25 50]);
plot([10 10],[min(ylim) max(ylim)],'k','LineWidth',LW/2,'LineStyle','-');
xticklabels(xticks-10);

set(gca,'FontSize',ax_fntSz,'LineWidth',ax_LW);

[lgd,lgd_props]=  legend({'|Qsame - Qdiff|','95th percentile','Firing Rate'});
unitAUC_Lines=findobj(lgd_props,'type','line');  % get the lines, not text
set(unitAUC_Lines,'linewidth',LW);            % set their width property
hold off

axes(b2_ax);
hold on
plot(BlockQdiffs{5},'LineWidth',LW,'color','k');
plot(xlim,[upperCI upperCI],'color',CT(9,:),'LineWidth',LW/2,'LineStyle','-.');
plot([BlockAha(5) BlockAha(5)],[upperCI upperCI],'+','color',CT(1,:),'LineWidth',LW/1,'MarkerSize',MkerSz);
ylabel('| Qsame - Qdiff |','FontSize',lbl_fntSz);
ylim([0 1]);
axis tight;
yticks([.2 , .4 , .6 ,.8]);
yyaxis right
plot((BlockFRs{5}),'LineWidth',LW,'color',CT2(5,:));
ylim([0 50]);
yticks([0 25 50]);
plot([10 10],[min(ylim) max(ylim)],'k','LineWidth',LW/2,'LineStyle','-');
set(gca,'FontSize',ax_fntSz,'LineWidth',ax_LW);
ylabel('Firing Rate (Hz)','FontSize',lbl_fntSz);
xticklabels(xticks-10);
hold off


axes(b3_ax);
hold on
plot(BlockQdiffs{3},'LineWidth',LW,'color','k');
plot(xlim,[upperCI upperCI],'color',CT(9,:),'LineWidth',LW/2,'LineStyle','-.');
plot([BlockAha(3) BlockAha(3)],[upperCI upperCI],'+','color',CT(1,:),'LineWidth',LW/1,'MarkerSize',MkerSz);
ylabel('| Qsame - Qdiff |','FontSize',lbl_fntSz);
ylim([0 1]);
axis tight;

yyaxis right
plot((BlockFRs{3}),'LineWidth',LW,'color',CT2(5,:));
ylabel('Firing Rate (Hz)','FontSize',lbl_fntSz);
xlabel('Trials Relative to Switch','FontSize',lbl_fntSz);
ylim([0 50]);
yticks([0 25 50]);
xticklabels(xticks-10);

plot([10 10],[min(ylim) max(ylim)],'k','LineWidth',LW/2,'LineStyle','-');
set(gca,'FontSize',ax_fntSz,'LineWidth',ax_LW);

hold off



axes(FrxBL_ax);
hold on
s_ix= contains(BlockRules,'same');
BLxFR_mdl = fitlm(BlockLens,FR_Change);
BL_b = BLxFR_mdl.Coefficients.Estimate(2);
BL_int = BLxFR_mdl.Coefficients.Estimate(1);

hold on
ylim([0 30]);
xlim([10 60]);
xticks([10 35 60]);
plot(BlockLens(s_ix),FR_Change(s_ix),'.','color',CT(SAME_c,:),'LineWidth',1,...
    'MarkerFaceColor',CT(SAME_c,:),'MarkerEdgeColor',CT(SAME_c,:),'MarkerSize',28);
plot(BlockLens(~s_ix),FR_Change(~s_ix),'.','color',CT(DIFF_c,:),'LineWidth',1,...
    'MarkerFaceColor',CT(DIFF_c,:),'MarkerEdgeColor',CT(DIFF_c,:),'MarkerSize',28);

plot([min(xlim) max(xlim)],[(min(xlim)*BL_b)+BL_int (max(xlim)*BL_b)+BL_int],'k','LineWidth',2);
xlabel('Block Length','FontSize',14);
ylabel('| \Delta Firing Rate (Hz) |','FontSize',14);
set(gca,'FontSize',ax_fntSz,'LineWidth',ax_LW);
legend({'Switch to Same','Switch to Diff'});



 
axes(CDF_ax);
hold on
CT3 =cbrewer('qual', 'Dark2', 8); 
hold on
plot(stdnrml_x,stdnrml_cdf,'color', CT(9,:),'LineWidth',LW);
plot(ecdf_x1,ecdf_f1,'color', CT(4,:),'LineWidth',LW);
plot([slope_median slope_median],[.5 .5],'+','color', 'k','MarkerSize',MkerSz,'LineWidth',LW);
xlim([-1 1])
ylim([0 1])
yticks([0 : max(ylim)/2 : max(ylim)]);

[~, cdf_lgd] = legend({'Standard Normal','Empirical CDF',['Median = ' num2str(slope_median,sigfigs)]});
 cdf_Lines=findobj(cdf_lgd,'type','line');  % get the lines, not text
 set(cdf_Lines,'linewidth',LW)            % set their width property
 


xlabel('Correlation Coefficient (R)','FontSize',lbl_fntSz);
ylabel('Cumulative Probability','FontSize',lbl_fntSz);
%annotation('textbox',[.17,.62 .2 .2],'String',summary_text,'FitBoxToText','on','FontSize',14,'EdgeColor','none');
R_CDF_ax = gca;
R_CDF_ax.FontSize = ax_fntSz;
R_CDF_ax.LineWidth = ax_LW; 
hold off






axes(Perm_ax);
hold on
ylim([0 .2]);
xlim([-.35 .35]);
ShuffledMedians = nanmedian(ShuffledCorrs)+.05;
plot([slope_median slope_median],[0 .2],'LineWidth',.01,'color', CT(9,:));
plot([slope_median slope_median],[0 .2],'LineWidth',LW,'color', CT(4,:));
histogram(ShuffledMedians,'BinWidth',2*max(xlim)/30,'Normalization','probability','FaceColor',CT(9,:),...
    'LineWidth',.5);


yticks([0 : max(ylim)/2 : max(ylim)]);
xticks([-.35 0 .35]);

xlabel('Median Correlation Coefficient (R)','FontSize',lbl_fntSz);
ylabel('Fraction','FontSize',lbl_fntSz);
Perm_ax.FontSize = ax_fntSz;
Perm_ax.LineWidth = ax_LW; 

[~, cdf_lgd] = legend({'Shuffled (n = 1000)','Obtained value'});
 cdf_Lines=findobj(cdf_lgd,'type','line');  % get the lines, not text
 set(cdf_Lines,'linewidth',LW)            % set their width property

  

 S_median_p = signrank(ShuffledMedians,slope_median);
 [S_med_string] = MakeP_string_v01(S_median_p);
%  annotation('textbox',[.61,.82 .01 .01],'String',['signrank ' S_med_string],...
%                           'FitBoxToText','on','FontSize',14,'EdgeColor','none');
perm_ax = gca;
perm_ax.FontSize = ax_fntSz;
perm_ax.LineWidth = ax_LW;
hold off



TF = 1;
return