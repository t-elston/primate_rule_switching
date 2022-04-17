function MakeImageControlFig_v01(ImageSelectivityTable)


CT2 =cbrewer('qual', 'Dark2', 8);


[meanCS,semCS] = GetMeanCI(ImageSelectivityTable.CSxpW2,'sem');
% regress CS against pW2
for i = size(ImageSelectivityTable.CSxpW2,1)
CS_ix(i,:) = 1:8;    
end

allCS = reshape(CS_ix,[],1);
allpW2=reshape(ImageSelectivityTable.CSxpW2,[],1);
[b,bint,r,rint,stats] = regress(allpW2,[ones(size(allCS)),allCS]);




[corrF,corrX] = ecdf(ImageSelectivityTable.Corr);
medianCorr = nanmedian(ImageSelectivityTable.Corr)+.04;
ShuffledCorrs = cell2mat(ImageSelectivityTable.ShuffledCorr);
ShuffledMedians = nanmedian(ShuffledCorrs)+.04;

 % make / plot a normal distribution for comparing slope distributions
 pd = makedist('Normal');
 stdnrml_x   = [-3:.1:3];
 stdnrml_cdf = cdf(pd,stdnrml_x);
 stdnrml_x = stdnrml_x/3;


 % get ready for plotting
 % standardize the font sizes
   lbl_fntSz = 14;
   ax_FntSz = 12;
   
   % standardize the line widths
   LW = 3;
   
   % standardize axis line width
   ax_LW = 1;
    
  ImFig = figure;
  set(ImFig, 'Position', [100 100 600 700]);   
  set(gcf,'renderer','Painters');  
  
  subplot(3,2,1);
  histogram(ImageSelectivityTable.SelectiveEpoch,'FaceColor',CT2(1,:));
  xticklabels({'Sample','Early D','Late D'});
  xlabel('Selective Epoch');
  ylabel('Num Units');
  set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

  
  
  subplot(3,2,2);
  histogram(ImageSelectivityTable.preferredImage,'FaceColor',CT2(1,:));
  xlabel('Preferred Image');
  set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

  
  subplot(3,2,3);
  hold on
  errorbar(meanCS,semCS,'.','CapSize',0,'LineWidth',LW,'MarkerSize',25,'color',CT2(1,:));
  X = [ones(size(meanCS')),[1:8]'];
  b = regress(meanCS',X);
  xlim([.5 8.5]);
  plot(xlim,xlim*b(2) + b(1),'LineWidth',1,'color',CT2(1,:)); 
  xlabel('Num Recent Hits');
  ylabel('p\omega^{2}');

  set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

  
  subplot(3,2,4);
  histogram(ImageSelectivityTable.ruleAUC,'FaceColor',CT2(1,:));
  xlim([0 1]);
  xlabel('Rule AUC');
  set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

  
  subplot(3,2,5);
  hold on
  plot(stdnrml_x,stdnrml_cdf,'LineWidth',LW,'color',CT2(1,:));
  plot(corrX,corrF,'LineWidth',LW,'color',CT2(8,:));
  xlabel('Firing Rate x Block Len Corr');
  hold off
  set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');

  
  subplot(3,2,6);
  hold on
  histogram(ShuffledMedians,'FaceColor',CT2(8,:));
  plot([medianCorr medianCorr],[ylim],'LineWidth',LW,'color',CT2(1,:));
  xlabel('Median Correlation');
  xlim([-.35 .35]);
  xticks([-.35 0 .35]);
  set(gca,'FontSize',ax_FntSz,'LineWidth',ax_LW,'color', 'none');


  




end % of function