
#install.packages('ggplot2')
#install.packages('ggpubr')
#install.packages('ggsci')
library(ggplot2)
library(ggpubr)
library(ggsci)
library(tools)
library(openxlsx)
library(dplyr)
setwd("PATH/DATA/HERE")
getwd()
data_psc_full <- read.table('beta_perception.txt',header = TRUE)

data_psc_full$Subject <- as.factor(data_psc_full$Subject)
data_psc_full$roi <- as.factor(data_psc_full$roi)
data_psc_full$roi_name <- as.character(data_psc_full$roi_name)


remove8104 = TRUE
if (remove8104) {
  data_psc <- data_psc_full[-which(data_psc_full$Subject== "8104"), ]
}
# list of ROIs
unique_rois <- unique(data_psc$roi)
ROI_label_plot = c('Right SPL', 'Left IPS','Right VI', 'Right VIIIb', 'Left PMd', 'Left SPL','Left M1', 'Left MD',
                   'Left PuM', 'Left VL', 'Left VPL', 'Right MD', 'Right VL','Right IPS')



####+++++++++++++++++++++++ Correlation plots of beta estimates with change in perception from baseline to final rotation block 


results_list <- list()

for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)
  plots <- list()
  # create a dataframe to store data for each roi
  summary_data <- data.frame(hand = numeric(), beta = numeric())
  
  # append to the summary_data 
  summary_data <- rbind(summary_data, data.frame( hand = roi_data$perception, beta = roi_data$betaPerception))

    if (as.numeric(r) %in% c(1,2,5,6,7,14)){ # ylim for cortical rois
    ylim_min <- -0.1 # 
    ylim_max <- 0.15
    interval <- (ylim_max - ylim_min) / 5 
  }else if (as.numeric(r) %in% 8:13){ # ylim for thalamic rois
    ylim_min <- -0.03
    ylim_max <- 0.06
    interval <- (ylim_max - ylim_min) / 3
  }else if (as.numeric(r) %in% c(3,4)){ # ylim for cerebellar rois
    ylim_min <- -0.06 
    ylim_max <- 0.08
    interval <- (ylim_max - ylim_min) / 7
  }
  
  spearman_result <- cor.test(summary_data$hand, summary_data$beta, method = "spearman")
  corr_result <- data.frame(
    corr_roi = paste("ROI",roi_data$roi[1],roi_data$roi_name[1]),
    test = as.factor("spearman"),
    R_value = as.numeric(spearman_result$estimate),
    p_value_raw = as.numeric(spearman_result$p.value),
    p_value_adjusted = NA  
  )
  # store the results 
  results_list[[as.character(r)]] <- corr_result
  
    # create ggplot
  p <- ggscatter(data = summary_data,
                 x = "hand",
                 y = "beta",
                 size = 1,
                 xlab = "Perception Change (�)",
                 ylab = "Beta Estimates",
                 title = paste("ROI",roi_data$roi[1],roi_data$roi_name[1]),
                 add = "reg.line",
                 conf.int = TRUE,
                 conf.int.level = 0.95,
                 add.params = list(color = "black", size = 1, linetype = 1, fill = "lightgray"),
                 cor.coef = TRUE,
                 cor.method = "spearman") +
   
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          text = element_text(size = 12), axis.text = element_text(colour = "black",size = 10),
          axis.ticks = element_line(colour = "black"))+
    coord_cartesian( ylim = c(ylim_min,ylim_max) ,xlim = c(-4,28)) +
    scale_y_continuous(breaks = seq(ylim_min, ylim_max, by = interval),expand = c(0, 0))+
    scale_x_continuous(breaks = seq(-4,28, by = 4), expand = c(0, 0)) 

  plots[[r]] <- p
  
  print(p)
  
  ggsave(paste("CorrROI",roi_data$roi[1], substr(file_path_sans_ext(roi_data$roi_name[1]), 1, 20),".pdf" ,sep = "")
         ,path = 'Figures//'
         ,device = 'pdf' ,width = 2.5, height = 2.5, units = "in",dpi = 300)
}
# adjust pvalues for the number of rois
p_values_for_adjustment <- sapply(results_list, function(x) x$p_value_raw)
adjusted_p_values <- p.adjust(p_values_for_adjustment, method = 'bonferroni', n = length(results_list)) 

# append adjusted p-values in the results list
for (i in seq_along(results_list)) {
  results_list[[names(results_list)[i]]]$p_value_adjusted <- adjusted_p_values[i]
}

# combine results into one data frame
group_results_df <- do.call(rbind, results_list)
write.xlsx(group_results_df, "corr_multipleComparisons.xlsx",rowNames= TRUE)










# a data frame to store summary data
summary_data <- data.frame(ROI = character(), Mean = numeric(), SE = numeric(), pvalue = numeric(), stringsAsFactors = FALSE)

# Loop over ROIs
for (r in unique_rois) {
  roi_data <- subset(data_psc, roi == r)
  
  print(shapiro.test(roi_data$betaPerception)$p.value)
  shapiro_test_result <- shapiro.test(roi_data$betaPerception)
  
  if (shapiro_test_result$p.value > 0.05) {
    # Use t-test for normally distributed data
    stats <- t.test(roi_data$betaPerception, conf.level = 0.95)
  } else {
    # Use Wilcoxon signed-rank test for non-normally distributed data
    stats <- wilcox.test(roi_data$betaPerception, conf.level = 0.95)
  }
  
  # Calculate mean and standard error
  mean_value <- mean(roi_data$betaPerception, na.rm = TRUE)
  se_value <- sd(roi_data$betaPerception, na.rm = TRUE) / sqrt(length(roi_data$betaPerception[!is.na(roi_data$betaPerception)]))
  
  # append to summary data frame
  summary_data <- rbind(summary_data, data.frame(ROI = roi_data$roi_name[1], Mean = mean_value, SE = se_value, pvalue = stats$p.value))
  
  
}
summary_data$Significance <- ifelse(summary_data$pvalue < 0.001, '***',
                                    ifelse(summary_data$pvalue < 0.01, '**',
                                           ifelse(summary_data$pvalue < 0.05, '*', 'n.s.')))
summary_data$RowNumber <- as.factor(1:nrow(summary_data))
summary_data$ROI_label_plot <- ROI_label_plot
ylim_min = -0.02 
ylim_max = 0.03 
# Plot
p <- ggplot(summary_data, aes(x = RowNumber, y = Mean)) +
  geom_col(fill = '#EF8354', width = 0.8) +
  
  geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE, color = '#EF8354'),width = 0, position = position_dodge(0.9)) +
  geom_text(aes(label = Significance,
                y = ifelse(Mean>0 ,Mean + SE, Mean - SE)), vjust = ifelse(summary_data$Mean > 0, -0.1, 1), size = 4) +
  
  labs(title = "ROI Summary", x = "ROI", y = "Predicted Beta", color = "black") +
  theme_pubr(x.text.angle = 45, base_size = 10) +
  scale_x_discrete(breaks = factor(1:nrow(summary_data)),labels = paste(substr(file_path_sans_ext(summary_data$ROI_label_plot), 1, 20))) + # Add this line to set x-axis labels
  coord_cartesian( ylim = c(ylim_min,ylim_max) ) +  # Set y-ais limits
  scale_y_continuous(breaks = seq(ylim_min, ylim_max, by = 0.01),expand = c(0, 0))+
  scale_color_manual(values = '#EF8354')+
  guides(fill = "none", color = "none") 

# Print the plot
print(p)

ggsave(paste("barplot_summaryROI",".pdf" ,sep = "") ,path = 'Figures/',
       device = "pdf" ,width = 4, height = 3, units = "in", dpi = 300)
