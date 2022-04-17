function [behavioral_data_for_plotting] = PlotBehavioralData_v03(block_data,behavioral_data)
behavioral_data_for_plotting = struct;

%----------------------------------------------------------------------
%                          Define color palette
%----------------------------------------------------------------------

   CT =cbrewer('qual', 'Set1', 9);   
   SAME_c  = 2;
   DIFF_c  = 1; 
   CDF_c = 3;
     
   CT2 = cbrewer('qual', 'Dark2', 8); 

   Zcol=CT2(1,:);
   Gcol=CT2(3,:);
   

   % standardize the font sizes
   lbl_fntSz = 15;
   ax_FntSz = 13;
   
   % standardize the line widths
   LW = 3;
   
   % standardize axis line width
   ax_LW = 1;
 
%----------------------------------------------------------------------

[BlockLens, chance_p,ALL_ttc] = Trials2critSimv02(10,8,13,5);
%----------------------------------------------------------------------
%                           MAKE FIGURE AND AXES
%----------------------------------------------------------------------
behavioral_fig = figure;   
set(behavioral_fig, 'Position', [10 50 600 700]);
set(gcf,'renderer','Painters');
%                                            X   Y   W    H
PCxpXc_ax               = axes('Position',[.1  .55  .35 .3]);
RTxpXc_ax               = axes('Position',[.6  .55  .35 .3]);
BLcdf_ax                = axes('Position',[.1  .15 .35 .3]);
WSLS_ax                 = axes('Position',[.6  .15 .35 .3]);

%---------------------------------------------------------------------- 
% % throw out outlier blocks and RTs
% blocks_to_discard = block_data.blockLen > 100;
% block_data(blocks_to_discard,:)=[];

RTs_to_discard = behavioral_data.RT > 1000;
behavioral_data(RTs_to_discard,:)=[];
%----------------------------------------------------------------------
%                MAKE SOME USEFUL INDICES
block_s_ix = contains(block_data.blockRule,'s');
block_d_ix = contains(block_data.blockRule,'d');
block_g_ix = contains(block_data.monkey,'G');
block_z_ix = contains(block_data.monkey,'Z');

trial_s_ix = contains(behavioral_data.rule,'s');
trial_d_ix = contains(behavioral_data.rule,'d');
trial_g_ix = contains(behavioral_data.FileName,'G');
trial_z_ix = contains(behavioral_data.FileName,'Z');
outcomes = double(contains(behavioral_data.outcome,'correct'));
CS = behavioral_data.cumSum;

axes(BLcdf_ax);
[chance_f, chance_x] = ecdf(ALL_ttc);
[Z_BL_f,Z_BL_x] = ecdf(block_data.blockLen(block_z_ix));
[G_BL_f,G_BL_x] = ecdf(block_data.blockLen(block_g_ix));

hold on
plot(Z_BL_x,Z_BL_f,'LineWidth',3,'color',Zcol);
plot(G_BL_x,G_BL_f,'LineWidth',3,'color',Gcol);
plot(chance_x,chance_f,'LineWidth',3,'color',CT2(8,:));
xlim([0 300]);
xlabel('Trials to Crit.');
ylabel('CDF');

legend({'Monkey Z','Monkey G','Chance'});
legend boxoff
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');
hold off

axes(RTxpXc_ax);
GS_RTs = block_data.pXc_RT(block_s_ix & block_g_ix,:);
GD_RTs = block_data.pXc_RT(block_d_ix & block_g_ix,:);

GS_pXc_RT_mean = nanmean(GS_RTs);
GS_pXc_RT_SEM = nanstd(GS_RTs) / sqrt(numel(GS_RTs(:,1)));

GD_pXc_RT_mean = nanmean(GD_RTs);
GD_pXc_RT_SEM = nanstd(GD_RTs) / sqrt(numel(GD_RTs(:,1)));

ZS_RTs = block_data.pXc_RT(block_s_ix & block_z_ix,:);
ZD_RTs = block_data.pXc_RT(block_d_ix & block_z_ix,:);

ZS_pXc_RT_mean = nanmean(ZS_RTs);
ZS_pXc_RT_SEM = nanstd(ZS_RTs) / sqrt(numel(ZS_RTs(:,1)));

ZD_pXc_RT_mean = nanmean(ZD_RTs);
ZD_pXc_RT_SEM = nanstd(ZD_RTs) / sqrt(numel(ZD_RTs(:,1)));

pXc_X = 1:numel(GS_pXc_RT_mean);


hold on
[RT1_lines,RT_patches] = boundedline(pXc_X, ZS_pXc_RT_mean,ZS_pXc_RT_SEM,...
                                     pXc_X, ZD_pXc_RT_mean,ZD_pXc_RT_SEM,... 
                                     pXc_X, GS_pXc_RT_mean,GS_pXc_RT_SEM,'-.',...
                                     pXc_X, GD_pXc_RT_mean,GD_pXc_RT_SEM,'-.',...    
                          'cmap',[CT(SAME_c,:) ; CT(DIFF_c,:);CT(SAME_c,:) ; CT(DIFF_c,:)]);
          
       RT1_lines(1).LineWidth = LW;
       RT1_lines(2).LineWidth = LW;
       RT1_lines(3).LineWidth = LW;
       RT1_lines(4).LineWidth = LW;
       plot([20 20],[min(ylim) max(ylim)],'k','LineWidth',1);
                    

 ylim([270 360]);     
 ylabel('RT (ms)','FontSize',lbl_fntSz);
 xticks([0: 5: 40]);
 xticklabels([-20:5:20]);
 xlabel('Trials from Switch','FontSize',lbl_fntSz);
 set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

 hold off
 
 
 
 
 
 
 

axes(WSLS_ax);
hold on
[WSLS_tbl] = compareWinStayLoseStay_v02(behavioral_data);
G_ix = WSLS_tbl.g_ix;
plot(WSLS_tbl.WS(~G_ix), WSLS_tbl.LS(~G_ix),'.','MarkerSize',20,'color',Zcol);
plot(WSLS_tbl.WS(G_ix), WSLS_tbl.LS(G_ix),'.','MarkerSize',20,'color',Gcol);
plot(WSLS_tbl.C_WS(G_ix), WSLS_tbl.C_LS(G_ix),'.','MarkerSize',20,'color',CT2(8,:));
plot(WSLS_tbl.C_WS(~G_ix), WSLS_tbl.C_LS(~G_ix),'.','MarkerSize',20,'color',CT2(8,:));

set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');
xlabel('p(Win-Stay)');
ylabel('p(Lose-Shift)');
xlim([.4 .7]);
ylim([.4 1]);
xticks([.4 .5 .6 .7]);
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');
xx=[];
hold off


axes(PCxpXc_ax);
GS_outcomes = block_data.pXc_outcome(block_s_ix & block_g_ix,:);
GD_outcomes = block_data.pXc_outcome(block_d_ix & block_g_ix,:);

GS_pXc_PC_mean = nanmean(GS_outcomes);
GS_pXc_PC_SEM = nanstd(GS_outcomes) / sqrt(numel(GS_outcomes(:,1)));

GD_pXc_PC_mean = nanmean(GD_outcomes);
GD_pXc_PC_SEM = nanstd(GD_outcomes) / sqrt(numel(GD_outcomes(:,1)));

ZS_outcomes = block_data.pXc_outcome(block_s_ix & block_z_ix,:);
ZD_outcomes = block_data.pXc_outcome(block_d_ix & block_z_ix,:);

ZS_pXc_PC_mean = nanmean(ZS_outcomes);
ZS_pXc_PC_SEM = nanstd(ZS_outcomes) / sqrt(numel(ZS_outcomes(:,1)));

ZD_pXc_PC_mean = nanmean(ZD_outcomes);
ZD_pXc_PC_SEM = nanstd(ZD_outcomes) / sqrt(numel(ZD_outcomes(:,1)));

pXc_X = 1:numel(GS_pXc_PC_mean);


hold on
[PC1_lines,PC_patches] = boundedline(pXc_X, ZS_pXc_PC_mean,ZS_pXc_PC_SEM,...
                                     pXc_X, ZD_pXc_PC_mean,ZD_pXc_PC_SEM,... 
                                     pXc_X, GS_pXc_PC_mean,GS_pXc_PC_SEM,'-.',...
                                     pXc_X, GD_pXc_PC_mean,GD_pXc_PC_SEM,'-.',...    
                          'cmap',[CT(SAME_c,:) ; CT(DIFF_c,:);CT(SAME_c,:) ; CT(DIFF_c,:)]);
          
       PC1_lines(1).LineWidth = LW;
       PC1_lines(2).LineWidth = LW;
       PC1_lines(3).LineWidth = LW;
       PC1_lines(4).LineWidth = LW;
       plot([20 20],[min(ylim) max(ylim)],'k','LineWidth',1);
                    
        [PC_lgd_props,PC_lgd]=legend(PC1_lines,{'SAME', 'DIFF','Monkey Z','Monkey G'},...
                    'FontSize',12, 'Location',[.45 .9 .01 .01]);
         rL=findobj(PC_lgd,'type','line');  % get the lines, not text
         set(rL,'linewidth',5)            % set their width property
         legend boxoff 
     
 ylabel('P(Correct)','FontSize',lbl_fntSz);
 xticks([0: 5: 40]);
 xticklabels([-20:5:20]);
 xlabel('Trials Relative To Switch','FontSize',lbl_fntSz);
set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

 hold off





 end % of function