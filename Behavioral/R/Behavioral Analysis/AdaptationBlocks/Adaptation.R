
library(effsize)  # for cohen.d function
library(afex)
library(rstatix)
library(carData)
library(car)
library(dplyr)
library(report)
library(openxlsx)
library(singcar)
library(gt)
# Adaptation Analysis
setwd('')

# ................... import data ........
data_fMRI_adap <- read.table('data_fMRI_adap_Group.txt',header = TRUE)
data_fMRI_adap$subject <-  as.factor(data_fMRI_adap$subject)
data_fMRI_adap$rotation <-  as.factor(data_fMRI_adap$rotation)
data_fMRI_adap$trialnum <-  as.numeric(data_fMRI_adap$trialnum)
data_fMRI_adap$block <-  as.factor(data_fMRI_adap$block)
data_fMRI_adap$handangle <-  as.numeric(data_fMRI_adap$handangle)

# .....get average of trials within each epoch per subject 
# last 10 trials within each block
data_fMRI_adap_epoch <- as.data.frame(data_fMRI_adap %>%
                                   group_by(subject,rotation,block) %>%
                                   slice_tail(n = 15) #for only the last ten trials selece 10 , for the whole block specificy 15
) 

# remove blocks 1 2 and 17 18 19 from the first anova to determine the effect of learning
filtered_data <- data_fMRI_adap_epoch %>%
  filter(!(rotation == 0 & block %in% c(17, 18, 19))) # to account for all baseline block remove baseline blocks
# take the average
data_adap_epoch_avg <- as.data.frame(filtered_data %>%
                                       group_by(subject, rotation) %>%
                                       summarise(handangle_avg = mean(handangle, na.rm = TRUE)) )

#run anova
anova.afex <- aov_car(handangle_avg ~  rotation + Error(subject/(rotation)), 
                      data = data_adap_epoch_avg ,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(anova.afex))
print(table_gt)

gt::gtsave(table_gt, file = "anova_table_adaptation_withCorrection_block.html")
write.xlsx(as.data.frame(table_gt), "anova_table_adaptation_withCorrection_block.xlsx",rowNames= TRUE)



#................... post-hoc comparisons .......


# specify the rotation levels for comparisons
rotation_levels <- c(0, 5, 10, 15, 20, 25,30)

# create an empty list to store the results
results_list <- list()
wb <- createWorkbook()

# perform pairwise t-tests and store results
for (i in 1:(length(rotation_levels) - 1)) {
  # Extract data for the two rotation levels
  data1 <- data_adap_epoch_avg[data_adap_epoch_avg$rotation == rotation_levels[i], ] 
  
  data2 <- data_adap_epoch_avg[data_adap_epoch_avg$rotation == rotation_levels[i+1], ] 
  
  # perform t-test
  print(shapiro.test(data1$handangle_avg- data2$handangle_avg)$p.value)
    t_test_result <- t.test(data1$handangle_avg, data2$handangle_avg, paired = TRUE)
    cohen_d <- cohen.d(data1$handangle_avg, data2$handangle_avg, method = "paired")
    
    # store results for this pair
    pairwise_result <- data.frame(
      comparison = paste("Rot", rotation_levels[i], "_vs_Rot", rotation_levels[i + 1]), 
      test = as.factor("ttest"),
      t_value = as.numeric(t_test_result$statistic),  # convert to numeric
      df = as.integer(t_test_result$parameter),  # convert to integer
      p_value_raw = as.numeric(t_test_result$p.value),  # convert to numeric
      p_value_adjusted = NA,
      cohen_d = as.numeric(cohen_d$estimate)  # convert to numeric
      
    )
  
  # append the results to results_list 
  results_list[[as.character(i)]] <- pairwise_result
}

# Adjust p-values using FDR
p_values_for_adjustment <- sapply(results_list, function(x) x$p_value_raw)
adjusted_p_values <- p.adjust(p_values_for_adjustment, method = 'fdr', n = length(results_list)) # 6 levels of comparison

# update adjusted p-values in the results_list
for (i in seq_along(results_list)) {
  results_list[[names(results_list)[i]]]$p_value_adjusted <- adjusted_p_values[i]
}

# merge results into one dataframe
group_results_df <- do.call(rbind, results_list)
write.xlsx(group_results_df, "PostHocComparison_block.xlsx",rowNames= TRUE)




##................................adaptation level ..............
#.............................. mean hand angle avg (block 16) - mean hand angle avg (block 3,4)

# keep only block 3,4,16
filtered_data_adapLevel <- data_fMRI_adap_epoch %>%
  filter((block %in% c(4,16)))
# take the average
data_adapLevel_avg <- as.data.frame(filtered_data_adapLevel %>%
                                       group_by(subject, rotation) %>%
                                       summarise(handangle_avg = mean(handangle, na.rm = TRUE)) )
adap_level <- data_adapLevel_avg[data_adapLevel_avg$rotation == 0,]$handangle_avg - 
               data_adapLevel_avg[data_adapLevel_avg$rotation == 30,]$handangle_avg
shapiro_test(adap_level)$p.value
wilcox.test(data_adapLevel_avg[data_adapLevel_avg$rotation == 0,]$handangle_avg, 
            data_adapLevel_avg[data_adapLevel_avg$rotation == 30,]$handangle_avg, paired = TRUE, alternative = "two.sided")
median(adap_level)
IQR(adap_level)
quantile(adap_level, 0.25)
quantile(adap_level, 0.75)


#..................................................................... after effect
#.......................run anova between baseline and three washout blocks
# baseline blocks 3 and 4 
# washout blocks 17 18 19
filtered_data_anovaAfterEffect <- data_fMRI_adap_epoch %>%
  filter(( block %in% c(1,2,3,4,17,18,19)))
data_anova_blocksbsl <- filtered_data_anovaAfterEffect[filtered_data_anovaAfterEffect$block == "1" | filtered_data_anovaAfterEffect$block == "2" |
                                                         filtered_data_anovaAfterEffect$block == "3" | filtered_data_anovaAfterEffect$block == "4", ]

data_anova_bsl <- as.data.frame(filtered_data_anovaAfterEffect[filtered_data_anovaAfterEffect$block == "3" | filtered_data_anovaAfterEffect$block == "4", ] %>%
                                  group_by(subject) %>%
                                  summarise(handangle_avg = mean(handangle, na.rm = TRUE)) )
data_anova_bsl$phase <- as.factor(rep("bsl", 30))
# washout1 - block 17
data_anova_block17 <-  as.data.frame(filtered_data_anovaAfterEffect[filtered_data_anovaAfterEffect$block == "17", ] %>%
                                       group_by(subject,block) %>%
                                       summarise(handangle_avg = mean(handangle, na.rm = TRUE)) )
data_anova_block17$phase <- as.factor(rep("w1", 30))
# washout2- block 18
data_anova_block18 <-  as.data.frame(filtered_data_anovaAfterEffect[filtered_data_anovaAfterEffect$block == "18", ] %>%
                                       group_by(subject,block) %>%
                                       summarise(handangle_avg = mean(handangle, na.rm = TRUE)) )
data_anova_block18$phase <- as.factor(rep("w2", 30))
#washout3-block19
data_anova_block19 <- as.data.frame(filtered_data_anovaAfterEffect[filtered_data_anovaAfterEffect$block == "19", ] %>%
                                      group_by(subject,block) %>%
                                      summarise(handangle_avg = mean(handangle, na.rm = TRUE)) )
data_anova_block19$phase <- as.factor(rep("w3", 30))
# combine all extracted blocks into one
combined_data_anova <- bind_rows(
  data_anova_bsl %>% select(subject, handangle_avg, phase),
  data_anova_block17 %>% select(subject, handangle_avg, phase),
  data_anova_block18 %>% select(subject, handangle_avg, phase),
  data_anova_block19 %>% select(subject, handangle_avg, phase),
)

# run anova
anova_aftereffect <- aov_car(handangle_avg  ~ phase + Error(subject/phase),
                             data = combined_data_anova,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(anova_aftereffect))
print(table_gt)
gt::gtsave(table_gt, file = "anova_table_aftereffect_BSL_Washout.html")
write.xlsx(as.data.frame(table_gt), "anova_table_aftereffect_BSL_Washout.xlsx",rowNames= TRUE)


#................... post-hoc comparisons .......


#washout3-washout1
datawashout3 <- combined_data_anova[combined_data_anova$phase == "w3", ] 
datawashout1 <- combined_data_anova[combined_data_anova$phase == "w1", ] 

shapiro.test(datawashout3$handangle_avg- datawashout1$handangle_avg)$p.value 
t_test_result_washout3to1 <- t.test(datawashout3$handangle_avg, datawashout1$handangle_avg, paired = TRUE)
cohen_d <- cohen.d(datawashout3$handangle_avg, datawashout1$handangle_avg, method = "paired")

# washout3-baseline
datawashout3 <- combined_data_anova[combined_data_anova$phase == "w3", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout3$handangle_avg- databsl$handangle_avg)$p.value 
t_test_result_washout3BSL <- t.test(datawashout3$handangle_avg, databsl$handangle_avg, paired = TRUE)
cohen_d <- cohen.d(datawashout3$handangle_avg, databsl$handangle_avg, method = "paired")
print(t_test_result_washout3BSL)
print(cohen_d)
#washout2 vs baselie
datawashout2 <- combined_data_anova[combined_data_anova$phase == "w2", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout2$handangle_avg- databsl$handangle_avg)$p.value 
t_test_result_washout2BSL <- t.test(datawashout2$handangle_avg, databsl$handangle_avg, paired = TRUE)
cohen_d <- cohen.d(datawashout2$handangle_avg, databsl$handangle_avg, method = "paired")
print(t_test_result_washout2BSL)
print(cohen_d)
# washout1 vs baselien
datawashout1 <- combined_data_anova[combined_data_anova$phase == "w1", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout1$handangle_avg- databsl$handangle_avg)$p.value 
t_test_result_washout1BSL <- t.test(datawashout1$handangle_avg, databsl$handangle_avg, paired = TRUE)
cohen_d <- cohen.d(datawashout1$handangle_avg, databsl$handangle_avg, method = "paired")
print(t_test_result_washout1BSL)
print(cohen_d)

p_values <- c(
  t_test_result_washout3to1$p.value,  
  t_test_result_washout3BSL$p.value,  
  t_test_result_washout2BSL$p.value,
  t_test_result_washout1BSL$p.value
)
adjusted_p_values <- p.adjust(p_values, method = "fdr")

















## comparison of adaptation level between aware and unaware subgroups - Neuroimage Revision Oct 2024
aware_subgroup <- c(10,13,17,21,22,27,29,34,36) # this is the subject label number as e.g., S10 S13 
# keep only block 3,4,16
filtered_data_adapLevel <- data_fMRI_adap_epoch %>%
  filter((block %in% c(4,16)))
# take the average
data_adapLevel_avg <- as.data.frame(filtered_data_adapLevel %>%
                                      group_by(subject, rotation) %>%
                                      summarise(handangle_avg = mean(handangle, na.rm = TRUE)) )

adap_level_subgroupCmp <- as.data.frame(data_adapLevel_avg %>% 
                                          group_by(subject) %>%
                                          summarise(adap_level = handangle_avg[rotation == 0] - 
                                                                 handangle_avg[rotation == 30])
                                        )


adap_level_aware <- adap_level_subgroupCmp[adap_level_subgroupCmp$subject %in% aware_subgroup,]$adap_level
adap_level_unaware <- adap_level_subgroupCmp[!adap_level_subgroupCmp$subject %in% aware_subgroup,]$adap_level
shapiro_test(adap_level_unaware)$p.value
shapiro_test(adap_level_aware)$p.value
# mann whithney u-test to compare two groups
resutls_mannWhitney <- wilcox.test(adap_level_aware,adap_level_unaware ,alternative = "two.sided")


anova.afex <- aov_car(handangle_avg ~  rotation + Error(subject/(rotation)), 
                      data = data_adap_epoch_avg ,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(anova.afex))
print(table_gt)



data_adap_epoch_avg_sub <- data_adap_epoch_avg %>%
  mutate(
    group = ifelse(subject %in% aware_subgroup, "aware", "unaware")
  )

anova_results <- aov_car(handangle_avg ~ group * rotation + Error(subject/rotation), data = data_adap_epoch_avg_sub,
                         anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(anova_results))
print(table_gt)



