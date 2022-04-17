function [UsedSelectivity, AllSelectivity] = getMaximallySelectivePeriodv02(SelectiveMoments,betas,minSel_len)
UsedSelectivity=[];
AllSelectivity =[];

    % based on the numTimeSteps, infer whether we are in the pre/post
    % choice period
    dummyArraySize = numel(betas);
    
    numTimeSteps = numel(SelectiveMoments);
    ValidSelectivityPeriod = zeros(numTimeSteps,1);
    if numTimeSteps > 2000               
     ValidSelectivityPeriod(200:2200) = 1; % fixation up until the choice
    else
        ValidSelectivityPeriod(:) = 1; % all parts of the post-choice period            
    end
    ValidSelectivityPeriod = logical(ValidSelectivityPeriod);
    analysisWindowStart = min(find(ValidSelectivityPeriod));
    analysisWindowEnd = max(find(ValidSelectivityPeriod));


AllSelectivity = SelectiveMoments;
SelectivityInRange = SelectiveMoments & ValidSelectivityPeriod';
[SelectivityStart, SelectivityLen, numEpochs] = ZeroOnesCount(SelectivityInRange(1,:));
        

valid_selective_periods = find(SelectivityLen>=minSel_len);        

if ~isempty(valid_selective_periods)
    
    
    if numel(valid_selective_periods)>1
        % find out which section to use
        epoch_to_use = [];
        % get the pW2 for the epochs
        beta_integrals=[];
        
        for e_ix = 1:numel(valid_selective_periods)
            beta_integrals(e_ix) = trapz(betas(SelectivityStart(e_ix):SelectivityStart(e_ix) + SelectivityLen(e_ix)-1));
        end % of cycling through the possible epochs
        
        % take the larger of the integrals
        [~,epoch_to_use] = max(beta_integrals);
        sel_epoch_start = SelectivityStart(epoch_to_use);
        sel_epoch_end   = SelectivityStart(epoch_to_use) + (SelectivityLen(epoch_to_use)-1);
    else
        sel_epoch_start = SelectivityStart(valid_selective_periods);
        sel_epoch_end   = sel_epoch_start +  (SelectivityLen(valid_selective_periods)-1);
        
    end % of determining which selective period to use
    
    % there are some cases where the selectivity is the entire trial
    % find the point of greatest selectivity and analyze it
    selectivityDuration = sel_epoch_end - sel_epoch_start;
    win_starts=[];
    win_ends=[];
    best_epoch_start=[];
    best_epoch_end=[];
    if selectivityDuration >= minSel_len
        % find 300 ms window with largest integral
%         window_integrals=[];
%         for w_ix = 1:selectivityDuration - 300
%             window_integrals(w_ix) = trapz(betas(sel_epoch_start+w_ix:sel_epoch_start+w_ix+300));
%             win_starts(w_ix) = sel_epoch_start+w_ix;
%             win_ends(w_ix) = sel_epoch_start+w_ix+300;
%         end
%        [~,bestWindow] = nanmax(window_integrals);
%        best_epoch_start = win_starts(bestWindow);
%        best_epoch_end   = win_ends(bestWindow);
% %         
        
        [~,pointOfMaxSelectivity] = max(betas(sel_epoch_start:sel_epoch_end));
        pointOfMaxSelectivity = (sel_epoch_start + pointOfMaxSelectivity)-1;
        % check 3 300ms windows for which one is maximally selective
        forwardWindowStart = pointOfMaxSelectivity;
        forwardWindowEnd   = pointOfMaxSelectivity+300;
        backwardWindowStart = pointOfMaxSelectivity-300;
        backwardWindowEnd = pointOfMaxSelectivity;
        centeredWindowStart = pointOfMaxSelectivity-150;
        centeredWindowEnd   = pointOfMaxSelectivity+150;
        
        if forwardWindowEnd > analysisWindowEnd
            forwardWindowEnd = analysisWindowEnd;
            forwardWindowStart = forwardWindowEnd -300;
        end
        
        if backwardWindowStart < analysisWindowStart
            backwardWindowStart = analysisWindowStart;
            backwardWindowEnd = backwardWindowStart +300;
        end
        
        if centeredWindowStart < analysisWindowStart
            centeredWindowStart = analysisWindowStart;
            centeredWindowEnd =centeredWindowStart+300;
        end
        
        if centeredWindowEnd > analysisWindowEnd
            centeredWindowEnd = analysisWindowEnd;
            centeredWindowStart = centeredWindowEnd-300;
        end
        
        forwardWindow_mean = NaN;
        backwardWindow_mean=NaN;
        centeredWindow_mean=NaN;
        
        forwardWindow_mean  = nanmean(betas(forwardWindowStart:forwardWindowEnd));
        backwardWindow_mean = nanmean(betas(backwardWindowStart:backwardWindowEnd));
        centeredWindow_mean = nanmean(betas(centeredWindowStart:centeredWindowEnd));
        
        forwardWindow_integral  = trapz(betas(forwardWindowStart:forwardWindowEnd));
        backwardWindow_integral = trapz(betas(backwardWindowStart:backwardWindowEnd));
        centeredWindow_integral = trapz(betas(centeredWindowStart:centeredWindowEnd));
        % find which one was best
        [~,bestWindow] = nanmax([forwardWindow_mean backwardWindow_mean centeredWindow_mean]);
        
        switch bestWindow
            case 1
                best_epoch_start = forwardWindowStart;
                best_epoch_end   = forwardWindowEnd;
                
            case 2
                best_epoch_start = backwardWindowStart;
                best_epoch_end   = backwardWindowEnd;
                
            case 3
                best_epoch_start = centeredWindowStart;
                best_epoch_end   = centeredWindowEnd;
        end % of setting the selectivity epoch length based on which window maximized selectivity
        
    end % of arbitrating between which section of selectivity to use
    
    
    % NOW MAKE THE RULE_SELECTIVE_MOMENTS ARRAY
    UsedSelectivity = NaN(dummyArraySize,1);
    UsedSelectivity(best_epoch_start:best_epoch_end) = 1;
    AllSelectivity(best_epoch_start:best_epoch_end) = 1;
    
else % if this unit didn't have a long-enough selectivity period, set all of it's periods to NaNs
     UsedSelectivity = NaN(dummyArraySize,1);
     AllSelectivity  = NaN(dummyArraySize,1);
    
end % of assessing selectivity, if there was any

return