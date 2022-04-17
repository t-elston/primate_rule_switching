function [WSLS_tbl] = compareWinStayLoseStay_v02(behavioral_data)
xx=[];

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
   ax_fntSz = 13;
   
   % standardize the line widths
   LW = 3;
   
   % standardize axis line width
   ax_LW = 1.5;
%----------------------------------------------------------------------
LP_WinStay=[];
LP_LoseShift=[];
HP_WinStay=[];
HP_LoseShift=[];
LP_ChanceWinStay=[];
LP_ChanceLoseShift=[];
HP_ChanceWinStay=[];
HP_ChanceLoseShift=[];
RealNumBlocks=[];
ChanceNumBlocks=[];

All_WinStay=[];
All_LoseShift=[];
All_WinStay2=[];
All_LoseShift2=[];
All_ChanceWinStay=[];
All_ChanceLoseShift=[];

all_WS =[];
all_LS=[];

monkeyLog=[];

% need to go through each session and get the win-stay, lose-stay probs vis
% a vis https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5452079/
monkeyIDs = {'G','Z'};
for m_ix = 1:numel(monkeyIDs)
  thisMonkey_ix = contains(behavioral_data.FileName,monkeyIDs(m_ix)); 
  thisMonkeyData = behavioral_data(thisMonkey_ix,:);
  
  SessionIDs = unique(thisMonkeyData.FileName);
  NumSessions = numel(SessionIDs);
  
  for s_ix = 1:NumSessions
      Sesh_ix = contains(thisMonkeyData.FileName,SessionIDs(s_ix));
      SeshData = thisMonkeyData(Sesh_ix,:);
      NumBlocksInSession = sum(contains(SeshData.blockStatus,'blockEnd'));

      LP_ix    = contains(SeshData.rel2Eureka,'Before');
      HP_ix    = contains(SeshData.rel2Eureka,'After');
      NP_ix    = ~(LP_ix | HP_ix);
      Hit_ix   = contains(SeshData.outcome,'correct');
      Miss_ix  = contains(SeshData.outcome,'error');
      Outcomes = double(Hit_ix);
      RuleChoice = SeshData.rule;
      
      % generate a chance array with the same number of trials as the real
      % session
      ChanceOutcomes = round(rand(numel(Outcomes*2),1));
      [chanceLP_ix, chanceHP_ix,numChanceBlocks] = chanceWSLS(ChanceOutcomes);
      
      ChanceHit_ix = ChanceOutcomes ==1;
      ChanceMiss_ix = ChanceOutcomes ==0;
      
      
      % find win-stay
      ShiftAmount = -1;
      LP_WinStay   = [LP_WinStay; nanmean(Outcomes(circshift(Hit_ix&LP_ix,ShiftAmount)))];
      LP_LoseShift = [LP_LoseShift; nanmean(Outcomes(circshift(Miss_ix&LP_ix,ShiftAmount)))];
      
      HP_WinStay   = [HP_WinStay; nanmean(Outcomes(circshift(Hit_ix&HP_ix,ShiftAmount)))];
      HP_LoseShift = [HP_LoseShift; nanmean(Outcomes(circshift(Miss_ix&HP_ix,ShiftAmount)))];
      
      LP_ChanceWinStay = [LP_ChanceWinStay; nanmean(ChanceOutcomes(circshift(ChanceHit_ix&chanceLP_ix,ShiftAmount)))];
      LP_ChanceLoseShift = [LP_ChanceLoseShift; nanmean(ChanceOutcomes(circshift(ChanceMiss_ix&chanceLP_ix,ShiftAmount)))];
      
      HP_ChanceWinStay   = [HP_ChanceWinStay; nanmean(ChanceOutcomes(circshift(ChanceHit_ix&chanceHP_ix,ShiftAmount)))];
      HP_ChanceLoseShift = [HP_ChanceLoseShift; nanmean(ChanceOutcomes(circshift(ChanceMiss_ix&chanceHP_ix,ShiftAmount)))];
      
      All_WinStay = [All_WinStay; nanmean(Outcomes(circshift(Hit_ix&~NP_ix,ShiftAmount)))];
      All_LoseShift = [All_LoseShift; nanmean(Outcomes(circshift(Miss_ix&~NP_ix,ShiftAmount)))];
      
      All_WinStay2 = [All_WinStay2; nanmean(Outcomes(circshift(Hit_ix ,ShiftAmount)))];
      All_LoseShift2 = [All_LoseShift2; nanmean(Outcomes(circshift(Miss_ix ,ShiftAmount)))];
      
      All_ChanceWinStay = [All_ChanceWinStay; nanmean(ChanceOutcomes(circshift(ChanceHit_ix&NP_ix,ShiftAmount)))];
      All_ChanceLoseShift = [All_ChanceLoseShift; nanmean(ChanceOutcomes(circshift(ChanceMiss_ix&NP_ix,ShiftAmount)))];
      
      for x = 1:5
        s_WS(x) =  nanmean(Outcomes(circshift(Hit_ix,(-1*x)))); 
        s_LS(x) =  nanmean(Outcomes(circshift(Miss_ix,(-1*x))));  
      end
      
      all_WS = [ all_WS;s_WS];
      all_LS = [all_LS;s_LS];
      
      
      
      monkeyLog = [monkeyLog;monkeyIDs(m_ix)];      
      RealNumBlocks   = [RealNumBlocks ; NumBlocksInSession];
      ChanceNumBlocks = [ChanceNumBlocks; numChanceBlocks];
      
  end % of cycling through each session
   
end % of cycling through each monkey

G_sesh_ix = contains(monkeyLog,'G');

WSLS_tbl = table;
WSLS_tbl.g_ix = G_sesh_ix;
WSLS_tbl.WS = All_WinStay;
WSLS_tbl.LS = All_LoseShift;
WSLS_tbl.C_WS = All_ChanceWinStay;
WSLS_tbl.C_LS = All_ChanceLoseShift;
%

% figure;
% hold on
% plot(All_WinStay2(~G_sesh_ix),All_LoseShift2(~G_sesh_ix),'.','MarkerSize',35,'color',Zcol);
% plot(All_WinStay2(G_sesh_ix),All_LoseShift2(G_sesh_ix),'.','MarkerSize',35,'color',Gcol);
%  plot(All_ChanceWinStay(G_sesh_ix),All_ChanceLoseShift(G_sesh_ix),'.','MarkerSize',35,'color',CT2(8,:));
%   plot(All_ChanceWinStay(~G_sesh_ix),All_ChanceLoseShift(~G_sesh_ix),'.','MarkerSize',35,'color',CT2(8,:));
% xlim([0 1]);
% ylim([0 1]);
% xlabel('p(Win-stay)','FontSize',14);
% ylabel('p(Lose-shift)','FontSize',14);
% title('Conditioned on Future Trial');
% 
% this_ax = gca;
% this_ax.FontSize = 20;
% this_ax.TickDir = 'out';
% this_ax.LineWidth = ax_LW; 
% 
%     [BL_lgd_props,BL_lgd_props]=legend({'Monkey Z','Monkey G','Binomial Chance'},...
%                     'FontSize',20, 'Location',[.7 .8 .01 .01]);
%          BL_rL=findobj(BL_lgd_props,'type','line');  % get the lines, not text
%          set(BL_rL,'linewidth',5)            % set their width property
%          legend boxoff 
% 
% hold off

% 
% 
% 
% 
% 
% figure;
% hold on
% plot(nanmean(all_WS(G_sesh_ix,:)),'color','b','LineWidth',2);
% plot(nanmean(all_LS(G_sesh_ix,:)),'color','b','LineStyle','-.','LineWidth',2);
% 
% plot(nanmean(all_WS(~G_sesh_ix,:)),'color','r','LineWidth',2);
% plot(nanmean(all_LS(~G_sesh_ix,:)),'color','r','LineStyle','-.','LineWidth',2);
% xlabel('n trials in past','FontSize',14);
% ylabel('prob.','FontSize',14);
% legend('G win-stay','G lose-shift','Z win-stay','Z lose-shift');
% xticks([1:5]);

% 
% figure;
% subplot(2,4,1)
% hold on
% plot(LP_WinStay(G_sesh_ix),LP_LoseShift(G_sesh_ix),'.','MarkerSize',30,'color',CT(2,:));
% plot(HP_WinStay(G_sesh_ix),HP_LoseShift(G_sesh_ix),'.','MarkerSize',30,'color',CT(1,:));
% plot(LP_ChanceWinStay(G_sesh_ix),LP_ChanceLoseShift(G_sesh_ix),'.','MarkerSize',25,'color',CT(9,:));
% plot(HP_ChanceWinStay(G_sesh_ix),HP_ChanceLoseShift(G_sesh_ix),'.','MarkerSize',25,'color',CT(9,:));
% plot(LP_WinStay(G_sesh_ix),LP_LoseShift(G_sesh_ix),'.','MarkerSize',30,'color',CT(2,:));
% plot(HP_WinStay(G_sesh_ix),HP_LoseShift(G_sesh_ix),'.','MarkerSize',30,'color',CT(1,:));
% xlim([0 1]);
% ylim([0 1]);
% title('Grover');
% xlabel('p(Win-stay)','FontSize',14);
% ylabel('p(Lose-shift)','FontSize',14);
% legend('Low Perf','High Perf', 'Chance');
% hold off
% % 
% subplot(2,4,2)
% hold on
% plot(LP_WinStay(~G_sesh_ix),LP_LoseShift(~G_sesh_ix),'.','MarkerSize',30,'color',CT(2,:));
% plot(HP_WinStay(~G_sesh_ix),HP_LoseShift(~G_sesh_ix),'.','MarkerSize',30,'color',CT(1,:));
% plot(LP_ChanceWinStay(~G_sesh_ix),LP_ChanceLoseShift(~G_sesh_ix),'.','MarkerSize',29,'color',CT(9,:));
% plot(HP_ChanceWinStay(~G_sesh_ix),HP_ChanceLoseShift(~G_sesh_ix),'.','MarkerSize',29,'color',CT(9,:));
% plot(LP_WinStay(~G_sesh_ix),LP_LoseShift(~G_sesh_ix),'.','MarkerSize',30,'color',CT(2,:));
% plot(HP_WinStay(~G_sesh_ix),HP_LoseShift(~G_sesh_ix),'.','MarkerSize',30,'color',CT(1,:));
% xlim([0 1]);
% ylim([0 1]);
% title('Ziggy');
% % xlabel('p(Win-stay)','FontSize',14);
% hold off
% 
% subplot(2,4,3)
% hold on
% plot(All_ChanceWinStay(G_sesh_ix),LP_ChanceLoseShift(G_sesh_ix),'.','MarkerSize',29,'color',CT(9,:));
% plot(All_WinStay(G_sesh_ix),All_LoseShift(G_sesh_ix),'.','MarkerSize',30);
% xlim([0 1]);
% ylim([0 1]);
% title('Grover');
% % xlabel('p(Win-stay)','FontSize',14);
% hold off
% 
% subplot(2,4,4)
% hold on
% plot(All_ChanceWinStay(~G_sesh_ix),LP_ChanceLoseShift(~G_sesh_ix),'.','MarkerSize',29,'color',CT(9,:));
% plot(All_WinStay(~G_sesh_ix),All_LoseShift(~G_sesh_ix),'.','MarkerSize',30);
% xlim([0 1]);
% ylim([0 1]);
% title('Ziggy');
% xlabel('p(Win-stay)','FontSize',14);
% hold off
% % 
% 
% 
% % let's validate the clustering via a k-nearest neighbor approach
% 
% % first, make a big array of all of the features for classification
% % one set of features and labels for each  monkey
% 
% % classifiers taking into account perf level
% G_FeatureTbl = table;
% G_LblArray             = [ones(numel(LP_WinStay(G_sesh_ix)),1) ;...
%                         ones(numel(LP_WinStay(G_sesh_ix)),1)*2 ;...
%                         ones(numel(LP_WinStay(G_sesh_ix)),1)*3 ;...
%                         ones(numel(LP_WinStay(G_sesh_ix)),1)*4];
%                                       
% G_FeatureTbl.WinStay   = [LP_WinStay(G_sesh_ix) ; HP_WinStay(G_sesh_ix);
%                           LP_ChanceWinStay(G_sesh_ix) ; HP_ChanceWinStay(G_sesh_ix)];
%                       
% G_FeatureTbl.LoseShift = [LP_LoseShift(G_sesh_ix) ; HP_LoseShift(G_sesh_ix);
%                           LP_ChanceLoseShift(G_sesh_ix) ;  HP_ChanceLoseShift(G_sesh_ix)];
% 
% 
% Z_FeatureTbl = table;
% Z_LblArray             = [ones(numel(LP_WinStay(~G_sesh_ix)),1) ;...
%                         ones(numel(LP_WinStay(~G_sesh_ix)),1)*2 ;...
%                         ones(numel(LP_WinStay(~G_sesh_ix)),1)*3;...
%                         ones(numel(LP_WinStay(~G_sesh_ix)),1)*4];
%                                       
% Z_FeatureTbl.WinStay   = [LP_WinStay(~G_sesh_ix) ; HP_WinStay(~G_sesh_ix);
%                           LP_ChanceWinStay(~G_sesh_ix) ;  HP_ChanceWinStay(~G_sesh_ix)];
%                       
% Z_FeatureTbl.LoseShift = [LP_LoseShift(~G_sesh_ix) ; HP_LoseShift(~G_sesh_ix);
%                           LP_ChanceLoseShift(~G_sesh_ix); HP_ChanceLoseShift(~G_sesh_ix)];
%                       
%                       
% % classifiers not taking into account perf level    
% G_FeatureTbl2 = table;
% G_LblArray2             = [ones(numel(LP_WinStay(G_sesh_ix)),1) ;...
%                            ones(numel(LP_WinStay(G_sesh_ix)),1)*2];
% 
% G_FeatureTbl2.WinStay   = [All_WinStay(G_sesh_ix) ; All_ChanceWinStay(G_sesh_ix)];  
% G_FeatureTbl2.LoseShift = [All_LoseShift(G_sesh_ix) ; All_ChanceLoseShift(G_sesh_ix)];  
% 
% Z_FeatureTbl2 = table;
% Z_LblArray2             = [ones(numel(LP_WinStay(~G_sesh_ix)),1) ;...
%                            ones(numel(LP_WinStay(~G_sesh_ix)),1)*2];
% 
% Z_FeatureTbl2.WinStay   = [All_WinStay(~G_sesh_ix) ; All_ChanceWinStay(~G_sesh_ix)];  
% Z_FeatureTbl2.LoseShift = [All_LoseShift(~G_sesh_ix) ; All_ChanceLoseShift(~G_sesh_ix)];  
% 
% for i = 1:1000  
% 
% % KNN CONSIDERING PERF LEVEL
% G_partition = randperm(numel(G_FeatureTbl.WinStay));
% G_train_ix = G_partition(1:round(.8*numel(G_partition)));
% G_test_ix  = G_partition(round(.8*numel(G_partition)):numel(G_partition));
% 
% Z_partition = randperm(numel(Z_FeatureTbl.WinStay));
% Z_train_ix = Z_partition(1:round(.8*numel(Z_partition)));
% Z_test_ix  = Z_partition(round(.8*numel(Z_partition)):numel(Z_partition));
% 
% % GROVER
% G_Mdl = fitcknn(G_FeatureTbl(G_train_ix,:),G_LblArray(G_train_ix),'NumNeighbors',5,'Standardize',1);
% [G_labels,~,~] = predict(G_Mdl,G_FeatureTbl(G_test_ix,:));
% G_accuracy(i) = nanmean(G_labels == G_LblArray(G_test_ix));
% 
% % ZIGGY
% Z_Mdl = fitcknn(Z_FeatureTbl(Z_train_ix,:),Z_LblArray(Z_train_ix),'NumNeighbors',5,'Standardize',1);
% [Z_labels,~,~] = predict(Z_Mdl,Z_FeatureTbl(Z_test_ix,:));
% 
% Z_accuracy(i) = nanmean(Z_labels == Z_LblArray(Z_test_ix));
% 
% % KNN -NOT- CONSIDERING PERF LEVEL
% G_partition2 = randperm(numel(G_FeatureTbl2.WinStay));
% G_train_ix2 = G_partition2(1:round(.8*numel(G_partition2)));
% G_test_ix2  = G_partition2(round(.8*numel(G_partition2)):numel(G_partition2));
% 
% Z_partition2 = randperm(numel(Z_FeatureTbl2.WinStay));
% Z_train_ix2 = Z_partition2(1:round(.8*numel(Z_partition2)));
% Z_test_ix2  = Z_partition2(round(.8*numel(Z_partition2)):numel(Z_partition2));
% 
% % GROVER
% G_Mdl2 = fitcknn(G_FeatureTbl2(G_train_ix2,:),G_LblArray2(G_train_ix2),'NumNeighbors',5,'Standardize',1);
% [G_labels2,~,~] = predict(G_Mdl2,G_FeatureTbl2(G_test_ix2,:));
% G_accuracy2(i) = nanmean(G_labels2 == G_LblArray2(G_test_ix2));
% 
% % ZIGGY
% Z_Mdl2 = fitcknn(Z_FeatureTbl2(Z_train_ix2,:),Z_LblArray2(Z_train_ix2),'NumNeighbors',5,'Standardize',1);
% [Z_labels2,~,~] = predict(Z_Mdl2,Z_FeatureTbl2(Z_test_ix2,:));
% 
% Z_accuracy2(i) = nanmean(Z_labels2 == Z_LblArray2(Z_test_ix2));
% 
% 
% end % of cycling through each iteration of the knn
% 
% subplot(2,4,5)
% hold on
% histogram(G_accuracy,10);
% xlim([0 1]);
% plot([.25 .25],[0 max(ylim)],'k','LineWidth',2);
% xlabel('KNN Classification Accuracy','FontSize',14);
% 
% 
% subplot(2,4,6)
% hold on
% histogram(Z_accuracy,10);
% xlim([0 1]);
% plot([.25 .25],[0 max(ylim)],'k','LineWidth',2);
% % xlabel('KNN Classification Accuracy','FontSize',14);
% 
% subplot(2,4,7)
% hold on
% histogram(G_accuracy2,10);
% xlim([0 1]);
% plot([.5 .5],[0 max(ylim)],'k','LineWidth',2);
% % xlabel('KNN Classification Accuracy','FontSize',14);
% 
% 
% subplot(2,4,8)
% hold on
% histogram(Z_accuracy2,10);
% xlim([0 1]);
% plot([.5 .5],[0 max(ylim)],'k','LineWidth',2);
% % xlabel('KNN Classification Accuracy','FontSize',14);

end % of function

% local function to assess chance low/high perf
function [chanceLP_ix, chanceHP_ix,numChanceBlocks] = chanceWSLS(ChanceOutcomes)
chanceHP_ix = zeros(numel(ChanceOutcomes),1);
chanceLP_ix = zeros(numel(ChanceOutcomes),1);
numChanceBlocks=[];

  block_ctr=0;
  buffer_pos = 0;
  Buffer = NaN(1,10);
  BlockChange = zeros(numel(ChanceOutcomes),1);
  ChanceCS=NaN(numel(ChanceOutcomes),1);
  
% go through the outcomes and find instances of 8/10 
for t_ix = 1:numel(ChanceOutcomes)
    buffer_pos = buffer_pos+1;
    block_ctr = block_ctr+1;
    Buffer(buffer_pos) = ChanceOutcomes(t_ix);
    
    ChanceCS(t_ix) = nansum(Buffer);
    
    % crit reached
    if (nansum(Buffer) >=8) & (block_ctr > 13)    
     ChanceCS(t_ix) = nansum(Buffer);
     % reset counters and buffer
     block_ctr=0;
     buffer_pos=0;
     Buffer = NaN(1,10);
     BlockChange(t_ix) = 1;
    end
    
    if buffer_pos > 9
        buffer_pos=0;
    end  
end % of cycling through the outcomes

% find the block changes
% cycle through the blocks
chanceBlockChange = find(BlockChange == 1);
numChanceBlocks = numel(chanceBlockChange);
for cb_ix = 1:numChanceBlocks
    if cb_ix > 1
     ThisBlockLen = chanceBlockChange(cb_ix) - chanceBlockChange(cb_ix-1);
    else
     ThisBlockLen = chanceBlockChange(cb_ix);
    end
    
    % find high perf periods of chance blocks
    chanceHP_ix(chanceBlockChange(cb_ix)-9:chanceBlockChange(cb_ix)) = 1;
    
    % find the low perf periods
    if ThisBlockLen >=20
       chanceLP_ix(chanceBlockChange(cb_ix)-19:chanceBlockChange(cb_ix)-10) = 1;
    else
        chanceLP_ix(chanceBlockChange(cb_ix)-ThisBlockLen+1 : chanceBlockChange(cb_ix)-10) = 1;
    end
    
end % of cycling through the blocks

end % of local function 