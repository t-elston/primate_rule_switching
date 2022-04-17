function [SelectivityTable] = calculateSelectivities_v08(onlyAssessSelective,DO_PERM_REGS,monkey,DATADIR)

% INPUTS
% PLOT_SELECTIVE_UNITS - can be 0 or 1, self-explanatory 
% monkey - determines which monkey's data to assess 
%          can be 'Ziggy','Grover', or 'both' (default)


        SAVEDIR = DATADIR;

% read in the data (.mat files)
fileList = dir(fullfile(DATADIR, '*.mat'));
FileNames = {fileList.name};

% remove the behavioral data part
FileNames(contains(FileNames,'BehavioralData')) = [];
FileNames(contains(FileNames,'SelectivityTable')) = [];
FileNames(contains(FileNames,'TrialMeanFRs')) = [];
FileNames(contains(FileNames,'EnsemblesOverTime.mat')) =[];
FileNames(contains(FileNames,'ClassificationData_v01.mat')) =[];


switch monkey    
    case 'Grover'
            files2use = contains(FileNames,'G');
            FileNames = FileNames(files2use);
        
    case 'Ziggy'
            files2use = contains(FileNames,'Z');
            FileNames = FileNames(files2use);        
end % of switch statement


if onlyAssessSelective
    load('SelectivityTable_v01.mat');
    fileList = SelectivityTable.beforeChoice.neuronName;
    FileNames={};
    for i = 1:numel(fileList)
        thisName = SelectivityTable.beforeChoice.neuronName(i);
      FileNames{i} = [thisName{1} '.mat'];
    end  
end

SelectivityTable = table;


    f = waitbar(0,'Assessing selectivity...');
    numFiles = numel(FileNames);
for f_ix = 1:numFiles
    
    thisUnitData = load([FileNames{f_ix}]); 
    thisUnitData = thisUnitData.thisUnitData;
    unitName = thisUnitData.NeuronName;
     waitbar(f_ix/numFiles,f,['Assessing ' unitName]);

      
         [tmp_SelectivityTable.beforeChoice,thisUnitData.beforeChoice] =...
             calculateSelctivities_v09p(thisUnitData.beforeChoice,0,DO_PERM_REGS);
         
         SelectivityTable = [ SelectivityTable ; tmp_SelectivityTable.beforeChoice];      
      
         
    % resave this unit's data
        saveFileName = [SAVEDIR thisUnitData.NeuronName '.mat'];
        save(saveFileName, 'thisUnitData');

end % of cycling through each neuron
waitbar(1,f,'Finished :]');
close(f);




return