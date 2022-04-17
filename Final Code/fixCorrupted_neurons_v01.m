function [thisUnitData] = fixCorrupted_neurons_v01(unitName,epoch)

eventNamesAndCodes_v01;

% find this data's file
ZIGGYDIR = 'D:\Data\Ziggy\ExtractedData';
GROVERDIR = 'D:\Data\Grover\ExtractedData';
            Z_fileList = dir(fullfile(ZIGGYDIR, '*.mat'));
            Z_FileNames = {Z_fileList.name};            
            G_fileList = dir(fullfile(GROVERDIR, '*.mat'));
            G_FileNames = {G_fileList.name};
            RecordingDates =  [G_FileNames Z_FileNames];
            
            unit_date = unitName{1}(1:7);
            unit_ID   = unitName{1}(9:15);
            
   % find the date this unit was recorded on
   date_ix = find(contains(RecordingDates,unit_date));
   thisDataFile = load(RecordingDates{date_ix});
   thisDataFile = thisDataFile.nexctx;
   
   % find this unit's data
   unit_ix = find(contains(thisDataFile.NeuronName,unit_ID));

    
   noextnfilename = thisDataFile.FileName;
% find out what happened during each trial and through out fix breaks
    [featureIndex,thisDataFile] = makeFeatureIndex_v02(thisDataFile,noextnfilename);
   
if contains(epoch,'aft')

      alignEvent  = 'SampleOn';
      alignOffset = -.7;  
[tmp_FSD_spikeTables,saveThisFile] = makeSpikeTable_v03(thisDataFile,unit_ix, featureIndex, EV, 'SampleOn', alignOffset, 2);
thisUnitData = tmp_FSD_spikeTables;
end

    if contains(epoch,'bef') 
[tmp_feedback_spikeTables,~] = makeSpikeTable_v03(thisDataFile,unit_ix, featureIndex, EV, 'FeedbackOn', -.5, .5);           
 thisUnitData = tmp_feedback_spikeTables;    
end
        




end