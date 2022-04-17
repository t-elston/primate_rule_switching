
% AssessPopCSxAUC.m
Stbl = SelectivityTable.beforeChoice;
PopCSxAUC   = cell2mat(Stbl.QxAUC);

n = numel(Stbl.preferredRule);

t_ix = [1:10]';
s_ix = ones(10,1);
d_ix = ones(10,1)*2;

fix_ix = ones(10,1);
sample_ix = ones(10,1)*2;
delay_ix  = ones(10,1)*3;

Rule=[];
AUC=[];
Epoch=[];
CS=[];

for i = 1:n
    
  AUC = [AUC; reshape(PopCSxAUC(i,:),[],1)];
  
  if contains(Stbl.preferredRule(i),'same')
      Rule=[Rule;s_ix];
  else
     Rule=[Rule;d_ix];
  end
  
    if contains(Stbl.SelectiveEpoch(i),'Fix')
      Epoch=[Epoch;fix_ix];
    elseif contains(Stbl.SelectiveEpoch(i),'Sample')
      Epoch=[Epoch;sample_ix];
    elseif contains(Stbl.SelectiveEpoch(i),'Delay')
      Epoch=[Epoch;delay_ix];
    end
  
    CS=[CS;t_ix];
    
end

tbl2 = table(AUC,CS,Rule,Epoch);
tbl2(isnan(tbl2.AUC),:)=[];

Rule = categorical(Rule);
Epoch = categorical(Epoch);
tbl = table(AUC,CS,Rule,Epoch);


% fit a model
mdl2 = fitglm(tbl2,'AUC ~  CS + CS*Rule+ CS*Epoch');
[B,Bnames,stats] = randomEffects(mdl);


