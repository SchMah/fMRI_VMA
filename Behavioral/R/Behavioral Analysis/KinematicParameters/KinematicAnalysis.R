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
data_fMRI_kin <- read.table('data_kinematic.txt',header = TRUE)
data_fMRI_kin$subject <-  as.factor(data_fMRI_kin$subject)
data_fMRI_kin$rotation <-  as.factor(data_fMRI_kin$rotation)
data_fMRI_kin$phase <-  as.factor(data_fMRI_kin$phase)
data_fMRI_kin$block <-  as.factor(data_fMRI_kin$block)
data_fMRI_kin$MT <-  as.numeric(data_fMRI_kin$MT)
data_fMRI_kin$RT <-  as.numeric(data_fMRI_kin$RT)


#++++++++++++++++++++++++++++++++++++++++++ analysis of movement time +++++++++ 
#+++++++++++++++++++++++++++++++++++++++++++ over the conditions (bsl, rot5, rot10,rot15,rot20, rot25, rot30)

#first select the blocks related to baseline and adaptation

data_fMRI_kin_adap <- data_fMRI_kin %>%
  filter(!(rotation == 0 & block %in% c(17, 18, 19)))
# average data per rotation per subject
Kin_MT_con_avg <- as.data.frame(data_fMRI_kin_adap %>%
                                      group_by(subject, rotation) %>%
                                      summarise(MT_avg = mean(MT, na.rm = TRUE)) )
model_MT_con <- aov_car(MT_avg ~ rotation + Error(subject/(rotation)), data = Kin_MT_con_avg, anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(model_MT_con))
print(table_gt)

# repeat the analysis with inclusion of all blocks (Supplementary S2)

model_MT_block <- aov_car(MT ~ block + Error(subject/(block)), data = data_fMRI_kin_adap,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(model_MT_block))
print(table_gt)
# this was significant , run post hoc : comparisons of interest 
#rotation5 vs baseline
# rotation 5 vs rotation 10 
# rotation 10 vs rotation 15
# rotation 15 vs rotation 20
#rotation 20 vs rotation 25
#rotation 25 vs rotation 30


block_levels <- c(4:16)
# create an empty list to store the results
results_list <- list()
wb <- createWorkbook()

# Perform pairwise t-tests and store results
for (i in seq(1, length(block_levels)-1, by = 2)) {
  # Extract data for the two rotation levels
  data1 <- data_fMRI_kin_adap[data_fMRI_kin_adap$block == block_levels[i], ] 
  
  data2 <- data_fMRI_kin_adap[data_fMRI_kin_adap$block == block_levels[i+1], ] 
  
  # Perform t-test
  print(shapiro.test(data1$MT- data2$MT)$p.value)
  t_test_result <- t.test(data1$MT, data2$MT, paired = TRUE)
  cohen_d <- cohen.d(data1$MT, data2$MT, method = "paired")
  
  # store results for this pair
  pairwise_result <- data.frame(
    comparison = paste("Rot", block_levels[i], "_vs_Rot", block_levels[i + 1]),  # Convert to character if necessary
    test = as.factor("ttest"),
    t_value = as.numeric(t_test_result$statistic),  # Convert to numeric
    df = as.integer(t_test_result$parameter),  # Convert to integer
    p_value_raw = as.numeric(t_test_result$p.value),  # Convert to numeric
    p_value_adjusted = NA,  # Placeholder for adjusted p-value
    cohen_d = as.numeric(cohen_d$estimate)  # Convert to numeric
    
  )
  
  # append the results to results_list
  results_list[[as.character(i)]] <- pairwise_result 
  
}

# Adjust p-values using FDR
p_values_for_adjustment <- sapply(results_list, function(x) x$p_value_raw)
adjusted_p_values <- p.adjust(p_values_for_adjustment, method = 'fdr', n = length(results_list)) # 6 levels of comparison

# Update adjusted p-values in the results_list
for (i in seq_along(results_list)) {
  results_list[[names(results_list)[i]]]$p_value_adjusted <- adjusted_p_values[i]
}

# combine results into one dataframe
group_results_df <- do.call(rbind, results_list)
print(group_results_df)
table_gt <- gt((group_results_df))
print(table_gt)




#++++++++++++++++++++++++++++++++++++++++++ analysis of movement time +++++++++ 
#+++++++++++++++++++++++++++++++++++++++++++ for the effect of washout and baseline

MT_data_aftereffect <- data_fMRI_kin %>%
  filter((block %in% c(1,2,3,4,17,18,19)))

data_anova_bsl <- as.data.frame(MT_data_aftereffect[MT_data_aftereffect$phase == "bsl", ] %>%
                                  group_by(subject) %>%
                                  summarise(MT = mean(MT, na.rm = TRUE)) )

data_anova_bsl$phase <- as.factor(rep("bsl", 30))

data_anova_block17 <-  as.data.frame(MT_data_aftereffect[MT_data_aftereffect$block == "17", ] %>%
                                       group_by(subject,block,MT) %>%
                                       summarise(MT = MT))

data_anova_block17$phase <- as.factor(rep("w1", 30))

data_anova_block18 <-  as.data.frame(MT_data_aftereffect[MT_data_aftereffect$block == "18", ] %>%
                                       group_by(subject,block,MT) %>%
                                       summarise(MT = MT))

data_anova_block18$phase <- as.factor(rep("w2", 30))
data_anova_block19 <-  as.data.frame(MT_data_aftereffect[MT_data_aftereffect$block == "19", ] %>%
                                       group_by(subject,block,MT) %>%
                                       summarise(MT = MT))

data_anova_block19$phase <- as.factor(rep("w3", 30))

combined_data_anova <- bind_rows(
  data_anova_bsl %>% select(subject, MT, phase),
  data_anova_block17 %>% select(subject, MT, phase),
  data_anova_block18 %>% select(subject, MT, phase),
  data_anova_block19 %>% select(subject, MT, phase),  
)


model_MT_washout <- aov_car(MT ~ phase + Error(subject/(phase)), data = combined_data_anova, anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(model_MT_washout))
print(table_gt)

# post hoc comparison # MT decreased significantly in first washout compared to the last adaptation step (1st comparison)
# and remained constant until the last washout phase (comparison2).

#washout3-washout1
datawashout3 <- combined_data_anova[combined_data_anova$phase == "w3", ] 
datawashout1 <- combined_data_anova[combined_data_anova$phase == "w1", ] 

shapiro.test(datawashout3$MT - datawashout1$MT)$p.value 
t_test_result_washout1to3 <- t.test(datawashout1$MT, datawashout3$MT, paired = TRUE)
print(t_test_result_washout1to3)
cohen_d <- cohen.d(datawashout1$MT, datawashout3$MT, method = "paired")

# washout1-baseline
datawashout1 <- combined_data_anova[combined_data_anova$phase == "w1", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout1$MT- databsl$MT)$p.value 
t_test_result_washout1BSL <- t.test(datawashout1$MT, databsl$MT, paired = TRUE)
cohen_d <- cohen.d(datawashout1$MT, databsl$MT, method = "paired")
print(t_test_result_washout1BSL)
print(cohen_d)

# washout2-baseline
datawashout2 <- combined_data_anova[combined_data_anova$phase == "w2", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout2$MT- databsl$MT)$p.value 
t_test_result_washout2BSL <- t.test(datawashout2$MT, databsl$MT, paired = TRUE)
cohen_d <- cohen.d(datawashout2$MT, databsl$MT, method = "paired")
print(t_test_result_washout2BSL)
print(cohen_d)

# washout3-baseline
datawashout3 <- combined_data_anova[combined_data_anova$phase == "w3", ] 
databsl <- combined_data_anova[combined_data_anova$phase == "bsl", ] 

shapiro.test(datawashout3$MT- databsl$MT)$p.value 
t_test_result_washout3BSL <- t.test(datawashout3$MT, databsl$MT, paired = TRUE)
cohen_d <- cohen.d(datawashout3$MT, databsl$MT, method = "paired")
print(t_test_result_washout3BSL)
print(cohen_d)

p_values <- c(
  t_test_result_washout1to3$p.value,  
  t_test_result_washout1BSL$p.value,
  t_test_result_washout2BSL$p.value,
  t_test_result_washout3BSL$p.value   # Replace with actual p-value from third t-test
  
)
adjusted_p_values <- p.adjust(p_values, method = "fdr")







########################################################## analysis of reaction time ##########################################

######################################################### analysis of reaction time for the adaptation phase #################

# average data per rotation per subject
Kin_RT_con_avg <- as.data.frame(data_fMRI_kin_adap %>%
                                  group_by(subject, rotation) %>%
                                  summarise(RT_avg = mean(RT, na.rm = TRUE)) )

model_RT_con <- aov_car(RT_avg ~ rotation + Error(subject/(rotation)), data = Kin_RT_con_avg,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(model_RT_con))
print(table_gt)

# repeat the analysis with inclusion of all blocks - Supplmenetary S3

model_RT_block <- aov_car(RT ~ block + Error(subject/(block)), data = data_fMRI_kin_adap,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(model_RT_block))
print(table_gt)

# none of the above revealed a significant effect



#++++++++++++++++++++++++++++++++++++++++++ analysis of reaction time +++++++++ 
#+++++++++++++++++++++++++++++++++++++++++++ for the effect of washout and rotation30

RT_data_aftereffect <- data_fMRI_kin %>%
  filter((block %in% c(1,2,3,4,17,18,19)))

data_anova_RTbsl <- as.data.frame(RT_data_aftereffect[RT_data_aftereffect$phase == "bsl", ] %>%
                                    group_by(subject) %>%
                                    summarise(RT = mean(RT, na.rm = TRUE)) )

data_anova_RTbsl$phase <- as.factor(rep("bsl", 30))

data_anova_RTblock17 <-  as.data.frame(RT_data_aftereffect[RT_data_aftereffect$block == "17", ] %>%
                                         group_by(subject,block) %>%
                                         summarise(RT = RT))
data_anova_RTblock17$phase <- as.factor(rep("w1", 30))


data_anova_RTblock18 <-  as.data.frame(RT_data_aftereffect[RT_data_aftereffect$block == "18", ] %>%
                                         group_by(subject,block) %>%
                                         summarise(RT = RT))
data_anova_RTblock18$phase <- as.factor(rep("w2", 30))

data_anova_Rblock19 <-  as.data.frame(RT_data_aftereffect[RT_data_aftereffect$block == "19", ] %>%
                                        group_by(subject,block) %>%
                                        summarise(RT = RT))

data_anova_Rblock19$phase <- as.factor(rep("w3", 30))

combined_RTdata_anova <- bind_rows(
  data_anova_RTbsl %>% select(subject, RT, phase),
  data_anova_RTblock17 %>% select(subject, RT, phase),
  data_anova_RTblock18 %>% select(subject, RT, phase),
  data_anova_Rblock19 %>% select(subject, RT, phase),  
)


model_RT_washout <- aov_car(RT ~ phase + Error(subject/(phase)), data = combined_RTdata_anova,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(model_RT_washout))
print(table_gt)


# repeating the analysis with block numbers 1 2 3 4 17 18 19 - Supplementary S4
model_RT <- aov_car(RT ~ block + Error(subject/(block)), data = RT_data_aftereffect,anova_table = list(es = "pes", correction="GG"))
table_gt <- gt(nice(model_RT))
print(table_gt)


