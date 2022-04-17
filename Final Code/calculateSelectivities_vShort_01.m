function [SelectivityTable] = calculateSelectivities_vShort_01(monkey,DATADIR)

% INPUTS
% PLOT_SELECTIVE_UNITS - can be 0 or 1, self-explanatory 
% monkey - determines which monkey's data to assess 
%          can be 'Ziggy','Grover', or 'both' (default)


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


SelectivityTable = table;

    f = waitbar(0,'Assessing selectivity...');
    numFiles = numel(FileNames);
for f_ix = 1:numFiles
    
    thisUnitData = load([FileNames{f_ix}]); 
    thisUnitData = thisUnitData.thisUnitData;
    unitName = thisUnitData.NeuronName;
     waitbar(f_ix/numFiles,f,['Assessing ' unitName]);
     
     % check if data are corrupted
     if isempty(fieldnames(thisUnitData.beforeChoice)) % if part of the file has been corrupted, compute it again
         thisUnitData.beforeChoice = fixCorrupted_neurons_v01(FileNames(f_ix),'beforeChoice');
     end
            
      
         [tmp_SelectivityTable,~] =calculateSelctivities_vShort_01p(thisUnitData.beforeChoice);
         
         SelectivityTable = [ SelectivityTable ; tmp_SelectivityTable];      
      
   
end % of cycling through each neuron
waitbar(1,f,'Finished :]');
close(f);




return