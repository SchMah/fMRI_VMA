#load libraries
library(ggplot2)
library(ggpubr)
library(tools)
library(dplyr)
library(openxlsx)

# load dataset
setwd("DATA/PATH/HERE")
getwd()
data_full <- read.table('beta_adaptation_beh.txt' ,header = TRUE)
data_full$subject <- as.factor(data_full$Subject)
data_full$roi <- as.factor(data_full$roi)

#decision after barplots.R was to exclude R-sPL and R-VL roi=1 and roi=13
roi_selection <- c(2:12, 14)
data_psc <- subset(data_full, roi %in% roi_selection)


data_psc <- data_psc %>%
  arrange(Subject) %>%
  mutate(row_number = row_number())

## +++++++++++++++++++++++++++++++++++++plot avg of hand and beta with 2D error bar

interests_toplot <- c('bsl1', 'bsl2', 'bsl3', 'bsl4', 'rot5a', 'rot5b', 'rot10a', 'rot10b', 'rot15', 'rot15run2',
                      'rot20a', 'rot20b', 'rot25a', 'rot25b', 'rot30a', 'rot30b')

interests_hand_toplot <- c('Hbsl1', 'Hbsl2', 'Hbsl3', 'Hbsl4', 'Hrot5a', 'Hrot5b', 'Hrot10a', 'Hrot10b', 'Hrot15', 'Hrot15run2',
                           'Hrot20a', 'Hrot20b', 'Hrot25a', 'Hrot25b', 'Hrot30a', 'Hrot30b')


results_list <- list()

# for each roi, correlation between each adaptation block and beta is plotted.
for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)

  summary_data <- data.frame(Condition = character(), Mean_hand = numeric(), mean_psc = numeric() , SE_hand = numeric(), SE_beta = numeric())
  
  # Loop over pairs of variables
  for (i in seq_along(interests_toplot)) {
    var_hand <- interests_hand_toplot[i]
    var_psc <- interests_toplot[i]
    
    hand <- roi_data[[var_hand]] * (-1)
    # Calculate mean for each variable
    mean_hand_block <- mean(hand)
    mean_psc_block <- mean(roi_data[[var_psc]])
    
    se_hand <- sd(hand, na.rm = TRUE) / sqrt(length(hand))
    se_beta <- sd(roi_data[[var_psc]], na.rm = TRUE) / sqrt(length(roi_data[[var_psc]]))
    
    # Append to the summary data frame
    summary_data <- rbind(summary_data, data.frame(Condition = var_psc, Mean_hand = mean_hand_block, Mean_psc = mean_psc_block , SE_hand = se_hand , SE_beta = se_beta))
  }
  print(max(summary_data$Mean_psc))
  print(min(summary_data$Mean_psc))
  if (as.numeric(r) %in% c(2,5,6,7,14)){ # cortical ROIs
    ylim_min <- 0
    ylim_max <- 1.5
    interval <- (ylim_max - ylim_min) / 5
  }else if (as.numeric(r) %in% 8:13){ #thalamic ROIs
    ylim_min <- -0.05
    ylim_max <- 0.4
    interval <- (ylim_max - ylim_min) / 5
  }else if (as.numeric(r) %in% c(3,4)){ # cerebellar ROIs
    ylim_min <- .2
    ylim_max <- 0.8
    interval <- (ylim_max - ylim_min) / 5
  }
  spearman_result <- cor.test(summary_data$Mean_hand, summary_data$Mean_psc, method = "spearman")
  corr_result <- data.frame(
    corr_roi = paste("ROI",roi_data$roi[1],roi_data$roi_name[1]), # Convert to character if necessary
    test = as.factor("spearman"),
    R_value = as.numeric(spearman_result$estimate),  # Convert to numeric
    p_value_raw = as.numeric(spearman_result$p.value),  # Convert to numeric
    p_value_adjusted = NA  # Placeholder for adjusted p-value
  )
  # Store the results
  results_list[[as.character(r)]] <- corr_result
  
  p <- ggplot(data = summary_data, aes(x = Mean_hand, y = Mean_psc)) + 
    geom_smooth(method = "lm", se = TRUE, color = "blue") +
    geom_errorbar(aes(ymin = Mean_psc - SE_beta, ymax = Mean_psc + SE_beta), width = 0, size = 0.5) + 
    geom_errorbarh(aes(xmin = Mean_hand - SE_hand, xmax = Mean_hand + SE_hand), height = 0 , size = 0.5)+
    geom_point( size= 2, fill="black", alpha = 0.5, stroke=NA)+
    
    stat_cor(label.x = min(summary_data$Mean_hand), label.y = ylim_max - interval,
             aes(label = paste(..rr.label.., ..p.label.., sep = "~~~")), 
             method = "spearman", size = 4, vjust = -1) +
    #theme_pubr(base_size = 12)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          text = element_text(size = 12), axis.text = element_text(colour = "black",size = 10),
          axis.ticks = element_line(colour = "black"))+
    labs(x = "Adaptation Level", y = "Predicted Beta", color = "black") +
    ggtitle(paste("ROI",roi_data$roi[1],roi_data$roi_name[1])) +
    coord_cartesian( ylim = c(ylim_min,ylim_max) ,xlim = c(-5,25)) +  # Set y-ais limits
    
    scale_y_continuous(breaks = seq(ylim_min, ylim_max, by = interval),expand = c(0, 0))+
    scale_x_continuous(breaks = seq(-5,25, by = 5), expand = c(0, 0))

  print(p)

  ggsave(paste("CorrROI",roi_data$roi[1], substr(file_path_sans_ext(roi_data$roi_name[1]), 1, 20),".pdf" ,sep = "") ,path = 'corrPlotsAllConditions12ROIs/'
         ,device = 'pdf' ,width = 2.5, height = 2.5, units = "in",dpi = 300)
  
}

p_values_for_adjustment <- sapply(results_list, function(x) x$p_value_raw)
adjusted_p_values <- p.adjust(p_values_for_adjustment, method = 'bonferroni', n = length(results_list)) # 6 levels of comparison

# Update adjusted p-values in the results list
for (i in seq_along(results_list)) {
  results_list[[names(results_list)[i]]]$p_value_adjusted <- adjusted_p_values[i]
}

# Combine results for this group into one data frame
group_results_df <- do.call(rbind, results_list)
write.xlsx(group_results_df, "corrPlotsAllConditions12ROIs/correlationResultsALlCondition.xlsx",rowNames= TRUE)






###++++++++++++++++++++++ same as above with avg per condition

interests_toplot <- c('avg_bsl', 'avg_rot5', 'avg_rot10', 'avg_rot15',
                      'avg_rot20',  'avg_rot25',  'avg_rot30')

interests_hand_toplot <- c('avg_Hbsl', 'avg_Hrot5', 'avg_Hrot10', 'avg_Hrot15',
                           'avg_Hrot20',  'avg_Hrot25',  'avg_Hrot30')
interests_toplot <- c('avg_rot5', 'avg_rot10', 'avg_rot15',
                      'avg_rot20',  'avg_rot25',  'avg_rot30')

interests_hand_toplot <- c( 'avg_Hrot5', 'avg_Hrot10', 'avg_Hrot15',
                            'avg_Hrot20',  'avg_Hrot25',  'avg_Hrot30')

results_list <- list()
# for each roi, correlation between each adaptation block and psc is plotted.
for (r in unique(data_psc$roi)) {
  #for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)
  subset_cols_1 <- roi_data[, c("bsl1", "bsl2", "bsl3", "bsl4")]
  subset_cols_2 <- roi_data[, c("rot5a", "rot5b")]
  subset_cols_3 <- roi_data[, c("rot10a", "rot10b")]
  subset_cols_4 <- roi_data[, c("rot15", "rot15run2")]
  subset_cols_5 <- roi_data[, c("rot20a", "rot20b")]
  subset_cols_6 <- roi_data[, c("rot25a", "rot25b")]
  subset_cols_7 <- roi_data[, c("rot30a", "rot30b")]
  # for hand angles
  subset_cols_h1 <- roi_data[, c("Hbsl1", "Hbsl2", "Hbsl3", "Hbsl4")]
  subset_cols_h2 <- roi_data[, c("Hrot5a", "Hrot5b")]
  subset_cols_h3 <- roi_data[, c("Hrot10a", "Hrot10b")]
  subset_cols_h4 <- roi_data[, c("Hrot15", "Hrot15run2")]
  subset_cols_h5 <- roi_data[, c("Hrot20a", "Hrot20b")]
  subset_cols_h6 <- roi_data[, c("Hrot25a", "Hrot25b")]
  subset_cols_h7 <- roi_data[, c("Hrot30a", "Hrot30b")]
  
  roi_data$avg_bsl <- rowMeans(subset_cols_1, na.rm = TRUE)
  roi_data$avg_rot5 <- rowMeans(subset_cols_2, na.rm = TRUE)
  roi_data$avg_rot10 <- rowMeans(subset_cols_3, na.rm = TRUE)
  roi_data$avg_rot15 <- rowMeans(subset_cols_4, na.rm = TRUE)
  roi_data$avg_rot20 <- rowMeans(subset_cols_5, na.rm = TRUE)
  roi_data$avg_rot25 <- rowMeans(subset_cols_6, na.rm = TRUE)
  roi_data$avg_rot30 <- rowMeans(subset_cols_7, na.rm = TRUE)
  
  roi_data$avg_Hbsl <- rowMeans(subset_cols_h1, na.rm = TRUE)
  roi_data$avg_Hrot5 <- rowMeans(subset_cols_h2, na.rm = TRUE)
  roi_data$avg_Hrot10 <- rowMeans(subset_cols_h3, na.rm = TRUE)
  roi_data$avg_Hrot15 <- rowMeans(subset_cols_h4, na.rm = TRUE)
  roi_data$avg_Hrot20 <- rowMeans(subset_cols_h5, na.rm = TRUE)
  roi_data$avg_Hrot25 <- rowMeans(subset_cols_h6, na.rm = TRUE)
  roi_data$avg_Hrot30 <- rowMeans(subset_cols_h7, na.rm = TRUE)
  
  
  
  summary_data <- data.frame(Condition = character(), Mean_hand = numeric(), mean_psc = numeric() , SE_hand = numeric(), SE_beta = numeric())
  
  # Loop over pairs of variables
  for (i in seq_along(interests_toplot)) {
    var_hand <- interests_hand_toplot[i]
    var_psc <- interests_toplot[i]
    
    hand <- roi_data[[var_hand]] * (-1)
    # Calculate mean for each variable
    mean_hand_block <- mean(hand)
    mean_psc_block <- mean(roi_data[[var_psc]])
    
    se_hand <- sd(hand, na.rm = TRUE) / sqrt(length(hand))
    se_beta <- sd(roi_data[[var_psc]], na.rm = TRUE) / sqrt(length(roi_data[[var_psc]]))
    
    # Append to the summary data frame
    summary_data <- rbind(summary_data, data.frame(Condition = var_psc, Mean_hand = mean_hand_block, Mean_psc = mean_psc_block , SE_hand = se_hand , SE_beta = se_beta))
  }
  print(max(summary_data$Mean_psc))
  print(min(summary_data$Mean_psc))
  if (as.numeric(r) %in% c(1,2,3,4,5,10,11,12,13,14,15,16,19)){
    ylim_min <- 0
    ylim_max <- 1.5
    interval <- (ylim_max - ylim_min) / 5
  }else if (as.numeric(r) %in% 20:30){
    ylim_min <- -0.05
    ylim_max <- 0.4
    interval <- (ylim_max - ylim_min) / 5
  }else if (as.numeric(r) %in% c(8,9)){
    ylim_min <- .2
    ylim_max <- 0.8
    interval <- (ylim_max - ylim_min) / 5
  }
  spearman_result <- cor.test(summary_data$Mean_hand, summary_data$Mean_psc, method = "spearman")
  corr_result <- data.frame(
    corr_roi = paste("ROI",roi_data$roi[1],roi_data$roi_name[1]), # Convert to character if necessary
    test = as.factor("spearman"),
    R_value = as.numeric(spearman_result$estimate),  # Convert to numeric
    p_value_raw = as.numeric(spearman_result$p.value),  # Convert to numeric
    p_value_adjusted = NA  # Placeholder for adjusted p-value
  )
  # Store the results
  results_list[[as.character(r)]] <- corr_result
  
  p <- ggplot(data = summary_data, aes(x = Mean_hand, y = Mean_psc)) + 
    geom_smooth(method = "lm", se = TRUE, color = "blue") +
    geom_errorbar(aes(ymin = Mean_psc - SE_beta, ymax = Mean_psc + SE_beta), width = 0, size = 0.5) + 
    geom_errorbarh(aes(xmin = Mean_hand - SE_hand, xmax = Mean_hand + SE_hand), height = 0 ,size = 0.5)+
    geom_point( size= 2, fill="black", alpha = 0.5, stroke=NA)+
    
    stat_cor(label.x = min(summary_data$Mean_hand), label.y = ylim_max - interval,
             aes(label = paste(..rr.label.., ..p.label.., sep = "~~~")), 
             method =  "spearman", size = 4, vjust = -1) +
    #theme_pubr(base_size = 12)+
    
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          text = element_text(size = 12), axis.text = element_text(colour = "black",size = 10),
          axis.ticks = element_line(colour = "black"))+
    
    labs(x = "Adaptation Level", y = "Predicted Beta", color = "black") +
    ggtitle(paste("ROI",roi_data$roi[1],roi_data$roi_name[1])) +
    coord_cartesian( ylim = c(ylim_min,ylim_max) ,xlim = c(-5,25)) + 
    
    scale_y_continuous(breaks = seq(ylim_min, ylim_max, by = interval),expand = c(0, 0))+
    scale_x_continuous(breaks = seq(-5,25, by = 5), expand = c(0, 0))
  
  print(p)
  # ggsave(paste("CorrROI",roi_data$roi[1], substr(file_path_sans_ext(roi_data$roi_name[1]), 1, 20),".pdf" ,sep = "") ,path = 'corrplotsMainConditions/'
  #        ,device = 'pdf' ,width = 2.5, height = 2.5, units = "in",dpi = 300)
}

p_values_for_adjustment <- sapply(results_list, function(x) x$p_value_raw)
adjusted_p_values <- p.adjust(p_values_for_adjustment, method = 'bonferroni', n = length(results_list)) # 6 levels of comparison

# Update adjusted p-values in the results list
for (i in seq_along(results_list)) {
  results_list[[names(results_list)[i]]]$p_value_adjusted <- adjusted_p_values[i]
}

# Combine results for this group into one data frame
group_results_df <- do.call(rbind, results_list)
























#++++++++++++++++++++++++++++++Individual block and hand data 


interests_toplot <- c('bsl1', 'bsl2', 'bsl3', 'bsl4', 'rot5a', 'rot5b', 'rot10a', 'rot10b', 'rot15', 'rot15run2',
                      'rot20a', 'rot20b', 'rot25a', 'rot25b', 'rot30a', 'rot30b','Washout.1','Washout.2','Washout.3')

interests_hand_toplot <- c('Hbsl1', 'Hbsl2', 'Hbsl3', 'Hbsl4', 'Hrot5a', 'Hrot5b', 'Hrot10a', 'Hrot10b', 'Hrot15', 'Hrot15run2',
                           'Hrot20a', 'Hrot20b', 'Hrot25a', 'Hrot25b', 'Hrot30a', 'Hrot30b','HWashout.1','HWashout.2','HWashout.3')


# Loop over ROIs
# for (r in unique(data_psc$roi[(1)])) {
for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)
  
  # Create a list to store ggplots
  
  plots <- list()
  # Loop over pairs of variables
  for (i in seq_along(interests_toplot)) {
    
    summary_data <- data.frame(Condition = character(), hand = numeric(), psc = numeric())
    var_hand <- interests_hand_toplot[i]
    var_psc <- interests_toplot[i]
    hand_block <- roi_data[[var_hand]]
    psc_block <- roi_data[[var_psc]]
    
    # Append to the summary data frame
    
    summary_data <- rbind(summary_data, data.frame(Condition = var_psc, hand = hand_block, psc = psc_block))
    # # Create ggplot
    # p <- ggplot(summary_data, aes(x = hand, y = psc)) +
    #   geom_point() +
    #   labs(title = paste("ROI", r)
    # )
    
    p <- ggscatter(data = summary_data,
                   x = "hand",
                   y = "psc",
                   xlab = "Hand Angle",
                   ylab = "psc%",
                   title = paste(interests_toplot[i]),
                   add = "reg.line",
                   conf.int = TRUE,
                   conf.int.level = 0.95,
                   add.params = list(color = "black", size = 1, linetype = 1, fill = "lightgray"),
                   cor.coef = TRUE,
                   cor.method = "spearman") +
      theme_pubr()
    # theme(figure.size = c(4, 4)) +
    # coord_fixed(ratio = 1)
    
    # Append the ggplot to the list
    #print(p)
    plots[[i]] <- p
    # Arrange and print the ggplots
    
    
  }
  
  
  fig <- ggarrange(plotlist = plots, ncol = 4, nrow = ceiling(length(plots)/4),
                   common.legend = TRUE) 
  annotate_figure(fig,bottom = text_grob(paste('ROI',roi_data$roi_name[1]), color = "blue",
                                         hjust = 1, x = 1, face = "italic", size = 10)
  )
  # annotate_figure(fig, top = text_grob(paste('ROI',roi_data$roi_name[1]), 
  #                                      color = "red", face = "bold", size = 14))
  print(fig)
  
  
  # # Save the figure
  # file_name <- paste('ROI',roi_data$roi_name[1], "_scatter_plots.png")
  # dev.print(png, file_name, width = 1200, height = 1200)
  # ggsave(paste("CorrROI",roi_data$roi[1], substr(file_path_sans_ext(roi_data$roi_name[1]), 1, 20),".pdf" ,sep = "") ,path = 'vel_CorrHand/'
  #        ,device = 'pdf' ,width = 12, height = 12, units = "in",dpi = 300)
}




interests_toplot <- c('avg_bsl', 'avg_rot5', 'avg_rot10', 'avg_rot15',
                      'avg_rot20',  'avg_rot25',  'avg_rot30')

interests_hand_toplot <- c('avg_Hbsl', 'avg_Hrot5', 'avg_Hrot10', 'avg_Hrot15',
                           'avg_Hrot20',  'avg_Hrot25',  'avg_Hrot30')

for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)
  #mean psc% over conditions
  subset_cols_1 <- roi_data[, c("bsl1", "bsl2", "bsl3", "bsl4")]
  subset_cols_2 <- roi_data[, c("rot5a", "rot5b")]
  subset_cols_3 <- roi_data[, c("rot10a", "rot10b")]
  subset_cols_4 <- roi_data[, c("rot15", "rot15run2")]
  subset_cols_5 <- roi_data[, c("rot20a", "rot20b")]
  subset_cols_6 <- roi_data[, c("rot25a", "rot25b")]
  subset_cols_7 <- roi_data[, c("rot30a", "rot30b")]
  # for hand angles
  subset_cols_h1 <- roi_data[, c("Hbsl1", "Hbsl2", "Hbsl3", "Hbsl4")]
  subset_cols_h2 <- roi_data[, c("Hrot5a", "Hrot5b")]
  subset_cols_h3 <- roi_data[, c("Hrot10a", "Hrot10b")]
  subset_cols_h4 <- roi_data[, c("Hrot15", "Hrot15run2")]
  subset_cols_h5 <- roi_data[, c("Hrot20a", "Hrot20b")]
  subset_cols_h6 <- roi_data[, c("Hrot25a", "Hrot25b")]
  subset_cols_h7 <- roi_data[, c("Hrot30a", "Hrot30b")]
  
  roi_data$avg_bsl <- rowMeans(subset_cols_1, na.rm = TRUE)
  roi_data$avg_rot5 <- rowMeans(subset_cols_2, na.rm = TRUE)
  roi_data$avg_rot10 <- rowMeans(subset_cols_3, na.rm = TRUE)
  roi_data$avg_rot15 <- rowMeans(subset_cols_4, na.rm = TRUE)
  roi_data$avg_rot20 <- rowMeans(subset_cols_5, na.rm = TRUE)
  roi_data$avg_rot25 <- rowMeans(subset_cols_6, na.rm = TRUE)
  roi_data$avg_rot30 <- rowMeans(subset_cols_7, na.rm = TRUE)
  
  roi_data$avg_Hbsl <- rowMeans(subset_cols_h1, na.rm = TRUE)
  roi_data$avg_Hrot5 <- rowMeans(subset_cols_h2, na.rm = TRUE)
  roi_data$avg_Hrot10 <- rowMeans(subset_cols_h3, na.rm = TRUE)
  roi_data$avg_Hrot15 <- rowMeans(subset_cols_h4, na.rm = TRUE)
  roi_data$avg_Hrot20 <- rowMeans(subset_cols_h5, na.rm = TRUE)
  roi_data$avg_Hrot25 <- rowMeans(subset_cols_h6, na.rm = TRUE)
  roi_data$avg_Hrot30 <- rowMeans(subset_cols_h7, na.rm = TRUE)
  
  plots <- list()
  # Loop over pairs of variables
  for (i in seq_along(interests_toplot)) {
    
    summary_data <- data.frame(Condition = character(), hand = numeric(), psc = numeric())
    var_hand <- interests_hand_toplot[i]
    var_psc <- interests_toplot[i]
    hand_block <- roi_data[[var_hand]]
    psc_block <- roi_data[[var_psc]]
    
    # Append to the summary data frame
    
    summary_data <- rbind(summary_data, data.frame(Condition = var_psc, hand = hand_block, psc = psc_block))
    # # Create ggplot
    # p <- ggplot(summary_data, aes(x = hand, y = psc)) +
    #   geom_point() +
    #   labs(title = paste("ROI", r)
    # )
    
    p <- ggscatter(data = summary_data,
                   x = "hand",
                   y = "psc",
                   xlab = "Hand Angle",
                   ylab = "psc%",
                   title = paste("ROI",roi_data$roi_name[as.numeric(r)]),
                   add = "reg.line",
                   conf.int = TRUE,
                   conf.int.level = 0.95,
                   add.params = list(color = "black", size = 1, linetype = 1, fill = "lightgray"),
                   cor.coef = TRUE,
                   cor.method = "spearman") +
      theme_pubr()
    # theme(figure.size = c(4, 4)) +
    # coord_fixed(ratio = 1)
    
    # Append the ggplot to the list
    #print(p)
    plots[[i]] <- p
    # Arrange and print the ggplots
    
    
  }
  fig <- ggarrange(plotlist = plots, ncol = 4, nrow = ceiling(length(plots)/4))
  print(fig)
  
}




## ++++++++++++++++++++++++++++++++++++++++++++++++ same as previous one with RT +++++++++++++++++++++++++++++

interests_toplot <- c('avg_bsl', 'avg_rot5', 'avg_rot10', 'avg_rot15',
                      'avg_rot20',  'avg_rot25',  'avg_rot30')

interests_hand_toplot <- c('avg_RTbsl', 'avg_RTrot5', 'avg_RTrot10', 'avg_RTrot15',
                           'avg_RTrot20',  'avg_RTrot25',  'avg_RTrot30')

for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)
  #mean psc% over conditions
  subset_cols_1 <- roi_data[, c("bsl1", "bsl2", "bsl3", "bsl4")]
  subset_cols_2 <- roi_data[, c("rot5a", "rot5b")]
  subset_cols_3 <- roi_data[, c("rot10a", "rot10b")]
  subset_cols_4 <- roi_data[, c("rot15", "rot15run2")]
  subset_cols_5 <- roi_data[, c("rot20a", "rot20b")]
  subset_cols_6 <- roi_data[, c("rot25a", "rot25b")]
  subset_cols_7 <- roi_data[, c("rot30a", "rot30b")]
  # for hand angles
  subset_cols_h1 <- roi_data[, c("RTbsl1", "RTbsl2", "RTbsl3", "RTbsl4")]
  subset_cols_h2 <- roi_data[, c("RTrot5a", "RTrot5b")]
  subset_cols_h3 <- roi_data[, c("RTrot10a", "RTrot10b")]
  subset_cols_h4 <- roi_data[, c("RTrot15", "RTrot15run2")]
  subset_cols_h5 <- roi_data[, c("RTrot20a", "RTrot20b")]
  subset_cols_h6 <- roi_data[, c("RTrot25a", "RTrot25b")]
  subset_cols_h7 <- roi_data[, c("RTrot30a", "RTrot30b")]
  
  roi_data$avg_bsl <- rowMeans(subset_cols_1, na.rm = TRUE)
  roi_data$avg_rot5 <- rowMeans(subset_cols_2, na.rm = TRUE)
  roi_data$avg_rot10 <- rowMeans(subset_cols_3, na.rm = TRUE)
  roi_data$avg_rot15 <- rowMeans(subset_cols_4, na.rm = TRUE)
  roi_data$avg_rot20 <- rowMeans(subset_cols_5, na.rm = TRUE)
  roi_data$avg_rot25 <- rowMeans(subset_cols_6, na.rm = TRUE)
  roi_data$avg_rot30 <- rowMeans(subset_cols_7, na.rm = TRUE)
  
  roi_data$avg_RTbsl <- rowMeans(subset_cols_h1, na.rm = TRUE)
  roi_data$avg_RTrot5 <- rowMeans(subset_cols_h2, na.rm = TRUE)
  roi_data$avg_RTrot10 <- rowMeans(subset_cols_h3, na.rm = TRUE)
  roi_data$avg_RTrot15 <- rowMeans(subset_cols_h4, na.rm = TRUE)
  roi_data$avg_RTrot20 <- rowMeans(subset_cols_h5, na.rm = TRUE)
  roi_data$avg_RTrot25 <- rowMeans(subset_cols_h6, na.rm = TRUE)
  roi_data$avg_RTrot30 <- rowMeans(subset_cols_h7, na.rm = TRUE)
  
  plots <- list()
  # Loop over pairs of variables
  for (i in seq_along(interests_toplot)) {
    
    summary_data <- data.frame(Condition = character(), hand = numeric(), psc = numeric())
    var_hand <- interests_hand_toplot[i]
    var_psc <- interests_toplot[i]
    hand_block <- roi_data[[var_hand]]
    psc_block <- roi_data[[var_psc]]
    
    # Append to the summary data frame
    
    summary_data <- rbind(summary_data, data.frame(Condition = var_psc, hand = hand_block, psc = psc_block))
    # # Create ggplot
    # p <- ggplot(summary_data, aes(x = hand, y = psc)) +
    #   geom_point() +
    #   labs(title = paste("ROI", r)
    # )
    
    p <- ggscatter(data = summary_data,
                   x = "hand",
                   y = "psc",
                   xlab = "RT",
                   ylab = "Predicted Beta",
                   title = paste("ROI",data_psc$roi_name[as.numeric(r)]),
                   add = "reg.line",
                   conf.int = TRUE,
                   conf.int.level = 0.95,
                   add.params = list(color = "black", size = 1, linetype = 1, fill = "lightgray"),
                   cor.coef = TRUE,
                   cor.method = "spearman") +
      theme_pubr()
    # theme(figure.size = c(4, 4)) +
    # coord_fixed(ratio = 1)
    
    # Append the ggplot to the list
    #print(p)
    plots[[i]] <- p
    # Arrange and print the ggplots
    
    
  }
  fig <- ggarrange(plotlist = plots, ncol = 4, nrow = ceiling(length(plots)/4))
  print(fig)
  
}


### ++++++++++++++++++++++++plot avg of RT and beta with 2D error bar

interests_toplot <- c('bsl1', 'bsl2', 'bsl3', 'bsl4', 'rot5a', 'rot5b', 'rot10a', 'rot10b', 'rot15', 'rot15run2',
                      'rot20a', 'rot20b', 'rot25a', 'rot25b', 'rot30a', 'rot30b')

interests_RT_toplot <- c('RTbsl1', 'RTbsl2', 'RTbsl3', 'RTbsl4', 'RTrot5a', 'RTrot5b', 'RTrot10a', 'RTrot10b', 'RTrot15', 'RTrot15run2',
                         'RTrot20a', 'RTrot20b', 'RTrot25a', 'RTrot25b', 'RTrot30a', 'RTrot30b')
# for each roi, correlation between each adaptation block and psc is plotted.
for (r in unique(data_psc$roi)) {
  #for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)
  
  
  summary_data <- data.frame(Condition = character(), Mean_hand = numeric(), mean_psc = numeric() , SE_hand = numeric(), SE_beta = numeric())
  
  # Loop over pairs of variables
  for (i in seq_along(interests_toplot)) {
    var_hand <- interests_RT_toplot[i]
    var_psc <- interests_toplot[i]
    
    # Calculate mean for each variable
    mean_hand_block <- mean(roi_data[[var_hand]])
    mean_psc_block <- mean(roi_data[[var_psc]])
    
    se_hand <- sd(roi_data[[var_hand]], na.rm = TRUE) / sqrt(length(roi_data[[var_hand]]))
    se_beta <- sd(roi_data[[var_psc]], na.rm = TRUE) / sqrt(length(roi_data[[var_psc]]))
    
    # Append to the summary data frame
    summary_data <- rbind(summary_data, data.frame(Condition = var_psc, Mean_hand = mean_hand_block, Mean_psc = mean_psc_block , SE_hand = se_hand , SE_beta = se_beta))
  }
  if (as.numeric(r) %in% c(1,2,3,4,5,10,11,12,13,14,15,16,19)){
    ylim_min <- 0
    ylim_max <- 1.5
    interval <- (ylim_max - ylim_min) / 5
  }else if (as.numeric(r) %in% 20:30){
    ylim_min <- -0.05
    ylim_max <- 0.4
    interval <- (ylim_max - ylim_min) / 5
  }else if (as.numeric(r) %in% c(8,9)){
    ylim_min <- .2
    ylim_max <- 0.8
    interval <- (ylim_max - ylim_min) / 5
  }
  
  p <- ggplot(data = summary_data, aes(x = Mean_hand, y = Mean_psc)) + geom_point() + #main graph
    geom_errorbar(aes(ymin = Mean_psc - SE_beta, ymax = Mean_psc + SE_beta)) + 
    geom_errorbarh(aes(xmin = Mean_hand - SE_hand, xmax = Mean_hand + SE_hand))+
    theme_pubr(base_size = 12)+
    ggtitle(paste("ROI",roi_data$roi[1],roi_data$roi_name[1]))+
    coord_cartesian( ylim = c(ylim_min,ylim_max) ,xlim = c(-25,5)) +  # Set y-ais limits
    
    scale_y_continuous(breaks = seq(ylim_min, ylim_max, by = interval),expand = c(0, 0))+
    scale_x_continuous(breaks = seq(-25, 5, by = 5), expand = c(0, 0))
  print(p)
}

