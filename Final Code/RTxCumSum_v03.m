function [xt] = RTxCumSum_v03(behavioral_data)
xt=[];

RT = behavioral_data.RT;
CS = behavioral_data.cumSum;
keepCS = ismember(CS,[1:8]);

hit_ix = contains(behavioral_data.outcome,'correct');
miss_ix = contains(behavioral_data.outcome,'error');


G_ix = contains(behavioral_data.FileName,'G');
Z_ix = contains(behavioral_data.FileName,'Z');

LP_ix = contains(behavioral_data.rel2Eureka,'Before');
HP_ix = contains(behavioral_data.rel2Eureka,'After');

[G_CS_RT_means,G_CS_RT_sem]  = grpstats(RT(G_ix & keepCS),CS(G_ix & keepCS),{'mean','sem'});
[Z_CS_RT_means,Z_CS_RT_sem]  = grpstats(RT(Z_ix & keepCS),CS(Z_ix & keepCS),{'mean','sem'});

[G_CS_PC_means,G_CS_PC_sem]  = grpstats(hit_ix(G_ix & keepCS),CS(G_ix & keepCS),{'mean','sem'});
[Z_CS_PC_means,Z_CS_PC_sem]  = grpstats(hit_ix(Z_ix & keepCS),CS(Z_ix & keepCS),{'mean','sem'});

[G_LP_f, G_LP_x] = ecdf(CS(G_ix & ~HP_ix & keepCS));
[G_HP_f, G_HP_x] = ecdf(CS(G_ix & HP_ix & keepCS));

[Z_LP_f, Z_LP_x] = ecdf(CS(Z_ix & ~HP_ix & keepCS));
[Z_HP_f, Z_HP_x] = ecdf(CS(Z_ix & HP_ix & keepCS));

% let's look at RTs during hits and misses
keepCSs = unique(CS(keepCS));
Z_hit_mean=[];
Z_hit_CI=[];
Z_miss_mean=[];
Z_miss_sem=[];

G_hit_mean=[];
G_hit_CI=[];
G_miss_mean=[];
G_miss_sem=[];
nbootstd =5;
numBoots = 1000;

Z_boot_mean = NaN(numBoots,numel(keepCSs));
G_boot_mean = NaN(numBoots,numel(keepCSs));

  [Z_hit_ci, Z_hit_bootstat] = bootci(1000,{@nanmean, RT(Z_ix & hit_ix)});
  [Z_miss_ci, Z_miss_bootstat] = bootci(1000,{@nanmean, RT(Z_ix & miss_ix)});
  

for c = 1:numel(keepCSs)
    this_cs = CS == keepCSs(c);
    
    [~, Z_cs_hit_bootstat] = bootci(1000,{@nanmean, RT(this_cs & Z_ix & hit_ix)},'nbootstd',20);
    [~, Z_cs_miss_bootstat] = bootci(1000,{@nanmean, RT(this_cs & Z_ix & miss_ix)},'nbootstd',20);
    
    [~, G_cs_hit_bootstat] = bootci(1000,{@nanmean, RT(this_cs & G_ix & hit_ix)},'nbootstd',20);
    [~, G_cs_miss_bootstat] = bootci(1000,{@nanmean, RT(this_cs & G_ix & miss_ix)},'nbootstd',20);
    
    Z_hit_mean(c,1) = nanmean(Z_cs_hit_bootstat);
    Z_hit_sem(c,1) = nanstd(Z_cs_hit_bootstat) / sqrt(numel(Z_cs_hit_bootstat));
    Z_miss_mean(c,1) = nanmean(Z_cs_miss_bootstat);
    Z_miss_sem(c,1) = nanstd(Z_cs_miss_bootstat) / sqrt(numel(Z_cs_miss_bootstat));
    
    G_hit_mean(c,1) = nanmean(G_cs_hit_bootstat);
    G_hit_sem(c,1) = nanstd(G_cs_hit_bootstat) / sqrt(numel(G_cs_hit_bootstat));
    G_miss_mean(c,1) = nanmean(G_cs_miss_bootstat);
    G_miss_sem(c,1) = nanstd(G_cs_miss_bootstat) / sqrt(numel(G_cs_miss_bootstat));
    
end % of cycling through CSs

% assess with glms
tbl = table;
tbl.CS = CS;
tbl.RT = RT;
tbl.hit = categorical(hit_ix);


figure;
subplot(3,2,1);
hold on
plot(G_HP_x,G_HP_f,'LineWidth',3);
plot(G_LP_x,G_LP_f,'LineWidth',3);
xlim([1 8]);
xticks([1:8]);
set(gca,'TickDir','Out','LineWidth',1.5,'FontSize',14);
ylabel('CDF');
legend({'High Perf' 'All other trials'},'FontSize',14);
legend boxoff
title('Monkey G','FontSize',14);

subplot(3,2,2);
hold on
plot(Z_HP_x,Z_HP_f,'LineWidth',3);
plot(Z_LP_x,Z_LP_f,'LineWidth',3);
xlim([1 8]);
xticks([1:8]);
set(gca,'TickDir','Out','LineWidth',1.5,'FontSize',14);
title('Monkey Z','FontSize',14);

subplot(3,2,3)
hold on
errorbar(G_CS_PC_means,G_CS_PC_sem,'LineWidth',3,'color','k');
ylabel('p(Correct)');
set(gca,'TickDir','Out','LineWidth',1.5,'FontSize',14);
xlim([1 8]);
xticks([1:8]);

subplot(3,2,4)
hold on
errorbar(Z_CS_PC_means,Z_CS_PC_sem,'LineWidth',3,'color','k');
ylabel('p(Correct)');
set(gca,'TickDir','Out','LineWidth',1.5,'FontSize',14);
xlim([1 8]);
xticks([1:8]);


subplot(1,2,1)
hold on
errorbar(G_hit_mean,G_hit_sem,'LineWidth',3,'color','k');
errorbar(G_miss_mean,G_miss_sem,'LineWidth',3,'color','k','LineStyle','-.');
ylabel('RT (ms)');
xlabel('Recent Hits out of 10');
set(gca,'TickDir','Out','LineWidth',1.5,'FontSize',14);
xlim([1 8]);
xticks([1:8]);
legend({'Correct' 'Error'},'FontSize',14);
legend boxoff
title('Monkey G');
G_mdl = fitglm(tbl(G_ix & keepCS,:),'RT ~ CS + CS*hit');


subplot(1,2,2)
hold on
errorbar(Z_hit_mean,Z_hit_sem,'LineWidth',3,'color','k');
errorbar(Z_miss_mean,Z_miss_sem,'LineWidth',3,'color','k','LineStyle','-.');
set(gca,'TickDir','Out','LineWidth',1.5,'FontSize',14);
xlim([1 8]);
xticks([1:8]);
title('Monkey Z');
Z_mdl = fitglm(tbl(Z_ix & keepCS,:),'RT ~ CS + CS*hit');



return