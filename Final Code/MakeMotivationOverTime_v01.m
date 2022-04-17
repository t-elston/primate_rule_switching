function [R_vals, p_vals] = MakeMotivationOverTime_v01(behavioral_data)
R_vals=[];
p_vals=[];

monkey_IDs = {'G' , 'Z'};
for m_ix = 1:numel(monkey_IDs)
    this_monkey_sessions_ix=[];
    SessionNames=[];
    tm_session_data=[];
    this_monkey_sessions_ix = contains(behavioral_data.FileName,monkey_IDs(m_ix));
    
    tm_session_data = behavioral_data(this_monkey_sessions_ix,:);
    SessionNames = unique(tm_session_data.FileName);
BLs=[];
switchNums=[];
all_blockLens = NaN(numel(SessionNames),30);
    CT =cbrewer('seq', 'Blues', numel(SessionNames)+5);
     CT2 =cbrewer('qual', 'Accent', 8); 
    figure;
    set(gcf,'renderer','Painters');
    hold on
    for s_ix = 1:numel(SessionNames)
        this_session_ix=[];
        this_session_data=[];
        this_session_ix = contains(tm_session_data.FileName,SessionNames(s_ix));
        this_session_data = tm_session_data(this_session_ix,:);
        
        % find the block lengths across the session
        blockEnds = find(contains(this_session_data.blockStatus,'blockEnd'));
        blockStarts = find(contains(this_session_data.blockStatus,'newBlockStart'));
        blockStarts = blockStarts(1:numel(blockEnds)); % ensures we only look at completed blocks
        trials2crit = blockEnds - blockStarts;
        trials2crit(trials2crit>200) = 200;
        plot(trials2crit,'color',CT(s_ix+5,:),'LineWidth',2);
        
        % accumulate an array for later correlation (or regression)
        snums = 1:numel(trials2crit);
        
        BLs = [BLs;trials2crit];
        switchNums = [switchNums ; snums'];
        all_blockLens(s_ix,1:numel(trials2crit)) = trials2crit;
        
    end % of cycling through sessions
[R_vals(m_ix) p_vals(m_ix)] = corr(switchNums(switchNums<14),BLs(switchNums<14));

plot(nanmedian(all_blockLens),'color',CT2(6,:),'LineWidth',4);
xlabel('Block in Session','FontSize',16);
ylabel('Trials to Criteria','FontSize',16);
ylim([0 200]);
R_ax = gca;
R_ax.FontSize = 14;
R_ax.TickDir = 'out';
R_ax.LineWidth = 1.5; 
  cb = colorbar('northoutside');
  cb.Position = [.65 .8 .2 .03 ];
  colormap(CT)

  hold off  
    
end % of cycling through each monkey





return