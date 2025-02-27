
library(effsize)  # for cohen.d function
library(afex)
library(rstatix)
library(carData)
library(car)
library(dplyr)
library(report)
library(openxlsx)
library(gt)
# Localization directory
setwd('')

# ................... import data ........
data_fMRI_Loc <- read.table('data_fMRI_Loc_Group.txt',header = TRUE)
data_fMRI_Loc$subject <-  as.factor(data_fMRI_Loc$subject)
data_fMRI_Loc$rotation <-  as.factor(data_fMRI_Loc$rotation)
data_fMRI_Loc$block <-  as.factor(data_fMRI_Loc$block)
data_fMRI_Loc$phase <-  as.factor(data_fMRI_Loc$phase)
data_fMRI_Loc$Perception <-  as.numeric(data_fMRI_Loc$Perception)



# remove blocks 1 and2 17 18 19 from the first anova for assessing the effect of learning
filtered_data <- data_fMRI_Loc %>%
  filter(!(rotation == 0 & block %in% c(17, 18, 19)))

data_perception_avg <- as.data.frame(filtered_data %>%
                                       group_by(subject, rotation) %>%
                                       summarise(perception_avg = mean(Perception, na.rm = TRUE)) )

#run anova
anova.afex <- aov_car(perception_avg ~  rotation + Error(subject/(rotation)), 
                      data = data_perception_avg ,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(anova.afex))
print(table_gt)


gt::gtsave(table_gt, file = "anova_table_localization_withCorrection.html")
write.xlsx(as.data.frame(table_gt), "anova_table_localization_withCorrection.xlsx",rowNames= TRUE)



#................... post-hoc comparisons for perception change  .......

# Specify the rotation levels for comparisons
rotation_levels <- c(0, 5, 10, 15, 20, 25,30)

# Create an empty list to store the results
results_list <- list()
wb <- createWorkbook()

# Perform pairwise t-tests and store results
for (i in 1:(length(rotation_levels) - 1)) {
  # Extract data for the two rotation levels
  data1 <- data_perception_avg[data_perception_avg$rotation == rotation_levels[i], ] 
  
  data2 <- data_perception_avg[data_perception_avg$rotation == rotation_levels[i+1], ] 
  
  # Perform t-test
  print(shapiro.test(data1$perception_avg- data2$perception_avg)$p.value)
  
  if (shapiro.test(data1$perception_avg- data2$perception_avg)$p.value > 0.05) {
    
    t_test_result <- t.test(data1$perception_avg, data2$perception_avg, paired = TRUE)
    cohen_d <- cohen.d(data1$perception_avg, data2$perception_avg, method = "paired")
    
    # Store results for this pair
    pairwise_result <- data.frame(
      comparison = paste("Rot", rotation_levels[i], "_vs_Rot", rotation_levels[i + 1]),  # convert to character if necessary
      test = as.factor("ttest"),
      t_value = as.numeric(t_test_result$statistic),  # convert to numeric
      df = as.integer(t_test_result$parameter),  # convert to integer
      p_value_raw = as.numeric(t_test_result$p.value),  # convert to numeric
      p_value_adjusted = NA,  # 
      cohen_d = as.numeric(cohen_d$estimate)  # convert to numeric
      
    )
  }else if (shapiro.test(data1$perception_avg- data2$perception_avg)$p.value < 0.05) {
    combined_data1 = data_perception_avg[data_perception_avg$rotation == rotation_levels[i] | data_perception_avg$rotation == rotation_levels[i+1], ]
    combined_data1$rotation <- as.numeric(combined_data1$rotation)
    
    wilcoxon_result <- rstatix::wilcox_test(formula = perception_avg ~ rotation ,
                                            data = combined_data1, paired = TRUE)
    effectsize_r = wilcox_effsize(formula = perception_avg ~ rotation, data = combined_data1,
                                  paired = TRUE)$effsize
    
    # store results for this target
    pairwise_result <- data.frame(
      comparison = paste("Rot", rotation_levels[i], "_vs_Rot", rotation_levels[i + 1]),  # convert to character if necessary
      test = as.factor("Wilcoxon"),
      t_value = as.numeric(wilcoxon_result$statistic),  # convert to numeric
      df = NA,  
      p_value_raw = as.numeric(wilcoxon_result$p),  # convert to numeric
      p_value_adjusted = NA,  
      cohen_d = as.numeric(effectsize_r)  # convert to numeric
      
    )
  }
  
  # append the results to the results_list
  results_list[[as.character(i)]] <- pairwise_result
}

# Adjust p-values using FDR
p_values_for_adjustment <- sapply(results_list, function(x) x$p_value_raw)
adjusted_p_values <- p.adjust(p_values_for_adjustment, method = 'fdr', n = length(results_list)) # 6 levels of comparison

# Update adjusted p-values in the results_list
for (i in seq_along(results_list)) {
  results_list[[names(results_list)[i]]]$p_value_adjusted <- adjusted_p_values[i]
}

# combine results for this group into one data frame
group_results_df <- do.call(rbind, results_list)
write.xlsx(group_results_df, "anova_table_loc_PostHocComparison.xlsx",rowNames= TRUE)





######.....................................perception by the end of adaptation relative to the baseline
filtered_data_loc <- data_fMRI_Loc %>%
  filter((block %in% c(3,4,16)))
# take the average
data_perc_avg <- as.data.frame(filtered_data_loc %>%
                                      group_by(subject, rotation) %>%
                                      summarise(perception_avg = mean(Perception, na.rm = TRUE)) )

perception_bsl <- data_perc_avg[data_perc_avg$rotation == "0", ]$perception_avg
perception_rot30 <- data_perc_avg[data_perc_avg$rotation == "30", ]$perception_avg

shapiro.test(perception_bsl - perception_rot30)$p.value
t.test(perception_bsl,perception_rot30,paired = TRUE)
cohen_d <- cohen.d(perception_bsl,perception_rot30, method = "paired")
mean(perception_bsl - perception_rot30 )
sd_percchange <- sd(perception_bsl - perception_rot30) # / sqrt(length(perception_bsl - perception_rot30))





###.................... after effect results of change in perception

filtered_data_AfterEffect <- data_fMRI_Loc %>%
  filter(( block %in% c(1,2,3,4,17,18,19)))


data_anova_bsl <- as.data.frame(filtered_data_AfterEffect[filtered_data_AfterEffect$block == "1" | filtered_data_AfterEffect$block == "2"|
                                                            filtered_data_AfterEffect$block == "3" | filtered_data_AfterEffect$block == "4", ] %>%
                                  group_by(subject) %>%
                                  summarise(Perception = mean(Perception, na.rm = TRUE)) )
data_anova_bsl$phase <- as.factor(rep("bsl", 30))

data_anova_block17 <-  as.data.frame(filtered_data_AfterEffect[filtered_data_AfterEffect$block == "17", ] %>%
                                       group_by(subject,block) %>%
                                       summarise(Perception = mean(Perception, na.rm = TRUE)) )
data_anova_block17$phase <- as.factor(rep("w1", 30))

data_anova_block18 <-  as.data.frame(filtered_data_AfterEffect[filtered_data_AfterEffect$block == "18", ] %>%
                                       group_by(subject,block) %>%
                                       summarise(Perception = mean(Perception, na.rm = TRUE)) )
data_anova_block18$phase <- as.factor(rep("w2", 30))

data_anova_block19 <- as.data.frame(filtered_data_AfterEffect[filtered_data_AfterEffect$block == "19", ] %>%
                                      group_by(subject,block) %>%
                                      summarise(Perception = mean(Perception, na.rm = TRUE)) )
data_anova_block19$phase <- as.factor(rep("w3", 30))

combined_data_anova <- bind_rows(
  data_anova_bsl %>% select(subject, Perception, phase),
  data_anova_block17 %>% select(subject, Perception, phase),
  data_anova_block18 %>% select(subject, Perception, phase),
  data_anova_block19 %>% select(subject, Perception, phase),
)

anova_aftereffect <- aov_car(Perception  ~ phase + Error(subject/phase),
                             data = combined_data_anova,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(anova_aftereffect))
print(table_gt)

gt::gtsave(table_gt, file = "anova_table_localization_GG_BSL_Washout_aftereffect.html")
write.xlsx(as.data.frame(table_gt), "anova_table_localization_GG_BSL_Washout_aftereffect.xlsx",rowNames= TRUE)

#................... post-hoc comparisons .......


# washout3-baseline
datawashout3 <- combined_data_anova[combined_data_anova$phase == "w3", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout3$Perception- databsl$Perception)$p.value 
t_test_result_washout3BSL <- t.test(datawashout3$Perception, databsl$Perception, paired = TRUE)
cohen_d <- cohen.d(datawashout3$Perception, databsl$Perception, method = "paired")
print(t_test_result_washout3BSL)
print(cohen_d)
#washout2 vs baselie
datawashout2 <- combined_data_anova[combined_data_anova$phase == "w2", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout2$Perception- databsl$Perception)$p.value 
t_test_result_washout2BSL <- t.test(datawashout2$Perception, databsl$Perception, paired = TRUE)
cohen_d <- cohen.d(datawashout2$Perception, databsl$Perception, method = "paired")
print(t_test_result_washout2BSL)
print(cohen_d)
# washout1 vs baselien
datawashout1 <- combined_data_anova[combined_data_anova$phase == "w1", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout1$Perception- databsl$Perception)$p.value 
t_test_result_washout1BSL <- t.test(datawashout1$Perception, databsl$Perception, paired = TRUE)
cohen_d <- cohen.d(datawashout1$Perception, databsl$Perception, method = "paired")
print(t_test_result_washout1BSL)
print(cohen_d)

p_values <- c(
  t_test_result_washout3BSL$p.value,  
  t_test_result_washout2BSL$p.value,
  t_test_result_washout1BSL$p.value
)
adjusted_p_values <- p.adjust(p_values, method = "fdr")













## comparison of change in perception between aware and unaware subgroup - Neuroimage Revision Oct 2024
aware_subgroup <- c(10,13,17,21,22,27,29,34,36) # this is the subject label number as e.g., S10 S13 


loc_level_subgroupCmp <- as.data.frame(data_perc_avg %>% 
                                          group_by(subject) %>%
                                          summarise(percChange = perception_avg[rotation == 0] - 
                                                      perception_avg[rotation == 30])
)


perc_level_aware <- loc_level_subgroupCmp[loc_level_subgroupCmp$subject %in% aware_subgroup,]$percChange
perc_level_unaware <- loc_level_subgroupCmp[!loc_level_subgroupCmp$subject %in% aware_subgroup,]$percChange
shapiro_test(perc_level_unaware)$p.value
shapiro_test(perc_level_aware)$p.value
# mann whithney u-test to compare two groups
wilcox.test(perc_level_aware,perc_level_unaware ,alternative = "two.sided")
