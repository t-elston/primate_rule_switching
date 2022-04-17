function [pvals, EffectSizes,rule_AUC] = doClassification_v01(FiringRates, Factors, AnalysisType,ShuffleTF)
pvals = NaN(3,1);
EffectSizes = NaN(3,1);

F1={};
F2={};
F3={};


switch ShuffleTF
    case 'shuffle'
        rng('shuffle');
        for fi = 1:numel(Factors)
            switch fi
                case 1
                    F1 = Factors{1};
                    F1 = F1(randi(numel(F1),1,numel(F1)));
                    
                case 2
                    F2 = Factors{2};
                    F2 = F2(randi(numel(F2),1,numel(F2)));
                    
                case 3
                    F3 = Factors{3};
                    F3 = F3(randi(numel(F3),1,numel(F3)));
            end % switch statement
        end % of cycling through the factors and shuffling them
        
        switch numel(Factors)
            
            case 2
                Factors ={F1, F2};
                
            case 3
                Factors ={F1, F2, F3};
        end % of switch statement
        
end % of shuffling factors for the permutation analysis





switch AnalysisType
    
    case 'anova'
        
        switch numel(Factors)
            
            case 2
                [pvals(1:numel(Factors),:),anova_tbl,~] = anovan(FiringRates,Factors,'varnames',{'rule' 'image'},'Display','off');
                
            case 3
                [pvals,anova_tbl,~] = anovan(FiringRates,Factors,'varnames',{'rule' 'image' 'action'},'Display','off');

        end % of switch statement
        
        % now calculate the partial omega squared
        [EffectSizes,VarNames] = calculatePartialW2_v01(anova_tbl,numel(FiringRates));

        
    case 'regression'
        
        % convert the factors into numeric predictors
        for f = 1:numel(Factors)
            reg_factors(:,f) = grp2idx(Factors{f});
        end
        
        stats = regstats(FiringRates,reg_factors,'linear',{'tstat','beta'});
        
        pvals(1:numel(Factors),:) = stats.tstat.pval(2:end);
        EffectSizes(1:numel(Factors),:) = abs(stats.beta(2:end));
end % of switch statement


rule_f = Factors{1};
try
[X,Y,T,rule_AUC] = perfcurve(rule_f,FiringRates,'same');
catch
 rule_AUC = NaN;
end









return % end of function