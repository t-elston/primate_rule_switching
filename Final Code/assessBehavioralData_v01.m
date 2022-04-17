function [block_data] = assessBehavioralData_v01(behavioral_data)
block_data=table;

% go through each session for each monkey and collect block length,
% reaction times, percent correct, etc

G_trial_ix = contains(behavioral_data.FileName,'G');
Z_trial_ix = contains(behavioral_data.FileName,'Z');

behavioral_struct.Grover = behavioral_data(G_trial_ix,:);
behavioral_struct.Ziggy = behavioral_data(Z_trial_ix,:);
monkeyIDs = fieldnames(behavioral_struct);

firstPostX1=NaN(100,2);
firstPostX2=[];


for m_ix = 1:numel(monkeyIDs)
    this_monkey_data = behavioral_struct.(monkeyIDs{m_ix});
    thismonkey = monkeyIDs{m_ix};
    
    % now identify the sessions
    session_IDs = unique(this_monkey_data.FileName);
    for s_ix = 1:numel(session_IDs)
        this_session_ix = contains(this_monkey_data.FileName,session_IDs(s_ix));
        this_session_data = this_monkey_data(this_session_ix,:);
         
       blockEnds = find(contains(this_session_data.blockStatus,'blockEnd')); 
       blockStarts = find(contains(this_session_data.blockStatus,'newBlockStarted'));
                   block_tbl=table;
       cs8s =    find(this_session_data.cumSum==8);         
       % now cycle through each block
       for b_ix = 1:numel(blockEnds)

           block_tbl.monkey{b_ix} = thismonkey;
           block_tbl.session(b_ix) = s_ix;
           
           thisBlock_ix = this_session_data.blockNum ==b_ix;
           thisBlock_data = this_session_data(thisBlock_ix,:);
           
           % now get the block length and find the preXcrit percent correct
           % and reaction times
           block_tbl.blockRule(b_ix,1) = thisBlock_data.rule(1);
           block_tbl.blockLen(b_ix,1) = numel(thisBlock_data.rule);
           block_tbl.sessionNum(b_ix,1) = s_ix;
           
           PreCrit_ix  = contains(thisBlock_data.rel2Eureka,'TenBeforeEureka');
           PreCrit_data = thisBlock_data(PreCrit_ix,:);
           PostCrit_ix = contains(thisBlock_data.rel2Eureka,'TenAfterEureka');
           PostCrit_data = thisBlock_data(PostCrit_ix,:);
         
           
           % find the first X trials after the switch
           X_trials = 10;
           nextBlock_outcome         = NaN(1,X_trials);
           nextBlock_RT              = NaN(1,X_trials);
           nextBlock_ModelConfidence = NaN(1,X_trials);
           nextBlock_SameEstimate    = NaN(1,X_trials);
           nextBlock_DiffEstimate    = NaN(1,X_trials);
           nextBlock_DiffEstimate    = NaN(1,X_trials);
           nextBlock_CumSum          = NaN(1,X_trials);
             
           if b_ix+1 <= numel(blockEnds)
               nextBlock_ix = this_session_data.blockNum ==b_ix+1;
               nextBlock_data = this_session_data(nextBlock_ix,:);
              
               % just skip the last blocks where there aren't enough trials
               AssessPostBlock = numel(nextBlock_data.rule) >= X_trials;
               if AssessPostBlock
              nextBlock_outcome = contains(nextBlock_data.outcome(1:X_trials),'correct')';
              nextBlock_RT = nextBlock_data.RT(1:X_trials)';
              nextBlock_ModelConfidence = nextBlock_data.ModelConfidence(1:X_trials)'; 
              nextBlock_SameEstimate = nextBlock_data.SameEstimates(1:X_trials)';
              nextBlock_DiffEstimate = nextBlock_data.DiffEstimates(1:X_trials)'; 
              nextBlock_CumSum = nextBlock_data.cumSum(1:X_trials)'; 
               end
           end 
           

           
           PreCrit_holder = NaN(1,10);
           PreCrit_RT              = PreCrit_holder;
           PreCrit_ModelConfidence = PreCrit_holder;
           PreCrit_SameEstimate    = PreCrit_holder;
           PreCrit_DiffEstimate    = PreCrit_holder;
           PreCrit_cumSum          = PreCrit_holder;
           
           numPreCrit =sum(PreCrit_ix);
           
           PreCrit_outcome(11-numPreCrit:10) = double(contains(PreCrit_data.outcome,'correct'))';
           PreCrit_RT(11-numPreCrit:10) = PreCrit_data.RT';
           PreCrit_ModelConfidence(11-numPreCrit:10) = PreCrit_data.ModelConfidence';
           PreCrit_SameEsimate(11-numPreCrit:10) = PreCrit_data.SameEstimates';
           PreCrit_DiffEstimate(11-numPreCrit:10) = PreCrit_data.DiffEstimates';
           PreCrit_cumSum(11-numPreCrit:10) = PreCrit_data.cumSum';
           
           
           PostCrit_outcome = double(contains(PostCrit_data.outcome,'correct'))';
           PostCrit_RT      = PostCrit_data.RT';
           PostCrit_ModelConfidence = PostCrit_data.ModelConfidence';
           PostCrit_SameEsimate = PostCrit_data.SameEstimates';
           PostCrit_DiffEstimate = PostCrit_data.DiffEstimates';
           PostCrit_cumSum = PostCrit_data.cumSum';
          
           % now put everything back together
           block_tbl.pXc_outcome(b_ix,:) = [PreCrit_outcome PostCrit_outcome nextBlock_outcome];
           block_tbl.pXc_RT(b_ix,:) = [PreCrit_RT PostCrit_RT nextBlock_RT];
           block_tbl.pXc_ModelConfidence(b_ix,:) = [PreCrit_ModelConfidence PostCrit_ModelConfidence nextBlock_ModelConfidence];
           block_tbl.pXc_SameEstimates(b_ix,:) = [PreCrit_SameEsimate PostCrit_SameEsimate nextBlock_SameEstimate];
           block_tbl.pXc_DiffEstimates(b_ix,:) = [PreCrit_DiffEstimate PostCrit_DiffEstimate nextBlock_DiffEstimate];
           block_tbl.pXc_cumSum(b_ix,:) = [PreCrit_cumSum PostCrit_cumSum nextBlock_CumSum];

           
           
       end % of cycling through each block
       
       % now save this data in an organized array
       block_data = [block_data ; block_tbl];
       
       try
    firstPostX1(s_ix,m_ix) =nanmean(contains(this_session_data.outcome(blockStarts),'correct')) ;
       catch
           firstPostX1(s_ix,m_ix) = NaN;
       end
%     firstPostX2(s_ix*m_ix) =nanmean(contains(this_session_data.outcome(cs8s+1),'correct')) ;
    end % of cycling through each session  
end % of cycling through each monkey
return