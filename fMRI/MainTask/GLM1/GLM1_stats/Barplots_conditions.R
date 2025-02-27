
#install.packages('ggplot2')
#install.packages('ggpubr')
#install.packages('ggsci')
library(ggplot2)
library(ggpubr)
library(ggsci)
library(tools)

setwd("DATA/PATH/HERE")
getwd()
data_full <- read.table('beta_adaptation_beh.txt',header = TRUE)
data_full$Subject <- as.factor(data_full$Subject)
data_full$roi <- as.factor(data_full$roi)
data_full$roi_name <- as.character(data_full$roi_name)


#how many ROIs?
unique_rois <- unique(data_full$roi)

#conditions of interest to plot
interests_toplot <- c('bsl1', 'bsl2', 'bsl3', 'bsl4', 'rot5a', 'rot5b', 'rot10a', 'rot10b', 'rot15', 'rot15run2',
                      'rot20a', 'rot20b', 'rot25a', 'rot25b', 'rot30a', 'rot30b','Washout.1','Washout.2','Washout.3')

colors <- c(rep('azure4', 4), rep('#78BCB0', 12), rep('azure4', 3))

# Loop over ROIs
for (r in unique(data_full$roi)) {
  roi_data <- subset(data_full, roi == r)
  
  # Create a data frame to store mean and standard error for each condition
  summary_data <- data.frame(Condition = character(), Mean = numeric(), SE = numeric(), pvalue = numeric())
  
  # Loop over conditions
  for (condition in interests_toplot) {
    condition_data <- roi_data[[condition]]
    
    # Calculate mean and standard error
    mean_value <- mean(condition_data, na.rm = TRUE)
    se_value <- sd(condition_data, na.rm = TRUE) / sqrt(length(condition_data[!is.na(condition_data)]))
    
    stats <- t.test(condition_data, conf.level = 0.95)
    
    # Append to summary data frame
    summary_data <- rbind(summary_data, data.frame(Condition = condition, Mean = mean_value, SE = se_value, pvalue = stats$p.value))
  }
  # make conditions as factor to be plotted in order
  summary_data$Condition <- factor(summary_data$Condition, levels = interests_toplot)

  # adjust the ylim  
  if (as.numeric(r) %in% c(1,2,5,6,7,14)){ # cortical ROIs
    ylim_min <- -0.2 
    ylim_max <-  1.8
    interval <- (ylim_max - ylim_min) / 10
  }else if (as.numeric(r) %in% 8:13){ # thalamic ROIs
    ylim_min <- -0.05
    ylim_max <- 0.4
    interval <- (ylim_max - ylim_min) / 9 
  }else if (as.numeric(r) %in% c(3,4)){ # cerebellar ROIs
    ylim_min <- 0
    ylim_max <- 0.8
    interval <- (ylim_max - ylim_min) / 5 
  }
  
  # Plot
  p <- ggplot(summary_data, aes(x = Condition, y = Mean)) +
    
    geom_col(aes(fill = factor(Condition)), width = 0.8) +
    geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE, color = factor(Condition)), width = 0, position = position_dodge(0.9)) +
    
    scale_fill_manual(values = colors) +
    scale_color_manual(values = colors) +
    guides(fill = "none", color = "none") +
    geom_text(aes(
      label = ifelse(pvalue < 0.001, '***', ifelse(pvalue < 0.01, '**', ifelse(pvalue < 0.05, '*', 'n.s.'))),
      y = ifelse(Mean>0 ,Mean + SE, Mean - SE)
    ), vjust = ifelse(summary_data$Mean > 0, -0.1, 1), size = 4) +
    labs(title = paste("ROI",roi_data$roi[1],roi_data$roi_name[1]), x = NULL , y = "Beta estimates", colour = "black") +
    theme_pubr(x.text.angle = 45, base_size = 10)+
    coord_cartesian( ylim = c(ylim_min,ylim_max) ) +  # Set y-ais limits
    scale_y_continuous(breaks = seq(ylim_min, ylim_max, by = interval),expand = c(0, 0))
  # Print the plot
  print(p)
  ggsave(paste("barROI",roi_data$roi[1], substr(file_path_sans_ext(roi_data$roi_name[1]), 1, 20),".pdf" ,sep = "") ,path = 'barPlotsAllConditions/',
           device = "pdf" ,width = 4, height = 3, units = "in", dpi = 300)
  
}



# bar plots of average of conditions 
interests_toplot <- c('avg_bsl1', 'avg_rot5', 'avg_rot10', 'avg_rot15',
                      'avg_rot20',  'avg_rot25',  'avg_rot30','avg_washout')
interests_toplot <- c('avg_bsl1', 'avg_rot30', 'Washout.1')

for (r in unique(data_psc$roi)) {
  roi_data <- subset(data_psc, roi == r)
  #mean psc% over conditions
  subset_cols_1 <- roi_data[, c("bsl1", "bsl2","bsl3", "bsl4")]
  #subset_cols_2 <- roi_data[, c("bsl3", "bsl4")]
  subset_cols_2 <- roi_data[, c("rot5a", "rot5b")]
  subset_cols_3 <- roi_data[, c("rot10a", "rot10b")]
  subset_cols_4 <- roi_data[, c("rot15", "rot15run2")]
  subset_cols_5 <- roi_data[, c("rot20a", "rot20b")]
  subset_cols_6 <- roi_data[, c("rot25a", "rot25b")]
  subset_cols_7 <- roi_data[, c("rot30a", "rot30b")]
  subset_cols_8 <- roi_data[, c("Washout.1", "Washout.2", "Washout.3")]
  
  roi_data$avg_bsl1 <- rowMeans(subset_cols_1, na.rm = TRUE)
  #roi_data$avg_bsl2 <- rowMeans(subset_cols_2, na.rm = TRUE)
  roi_data$avg_rot5 <- rowMeans(subset_cols_2, na.rm = TRUE)
  roi_data$avg_rot10 <- rowMeans(subset_cols_3, na.rm = TRUE)
  roi_data$avg_rot15 <- rowMeans(subset_cols_4, na.rm = TRUE)
  roi_data$avg_rot20 <- rowMeans(subset_cols_5, na.rm = TRUE)
  roi_data$avg_rot25 <- rowMeans(subset_cols_6, na.rm = TRUE)
  roi_data$avg_rot30 <- rowMeans(subset_cols_7, na.rm = TRUE)
  roi_data$avg_washout <- rowMeans(subset_cols_8, na.rm = TRUE)  
  # Create a data frame to store mean and standard error for each condition
  summary_data <- data.frame(Condition = character(), Mean = numeric(), SE = numeric(), pvalue = numeric())
  
  plots <- list()
  # Loop over pairs of variables
  for (condition in interests_toplot) {
    
    condition_data <- roi_data[[condition]]
    mean_value <- mean(condition_data, na.rm = TRUE)
    se_value <- sd(condition_data, na.rm = TRUE) / sqrt(length(condition_data[!is.na(condition_data)]))
    
    stats <- t.test(condition_data, conf.level = 0.95)
    summary_data <- rbind(summary_data, data.frame(Condition = condition, Mean = mean_value, SE = se_value, pvalue = stats$p.value))
  }
  
  # make conditions as factor to be plotted in order
  summary_data$Condition <- factor(summary_data$Condition, levels = interests_toplot)    
  # Append to the summary data frame
  
  # Plot
  p <- ggplot(summary_data, aes(x = Condition, y = Mean)) +
    geom_col(aes(fill = factor(Condition)), width = 0.8) +
    geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE, color = factor(Condition)), width = 0, position = position_dodge(0.9)) +
    scale_fill_manual(values = colors) +
    scale_color_manual(values = colors) +
    guides(fill = "none", color = "none") +
    geom_text(aes(
      label = ifelse(pvalue < 0.001, '***', ifelse(pvalue < 0.01, '**', ifelse(pvalue < 0.05, '*', 'n.s.'))),
      #y = max(summary_data$Mean) + 0.8 * (ifelse(summary_data$Mean > 0, 1, -1)) * (max(summary_data$Mean + summary_data$SE) - min(summary_data$Mean - summary_data$SE))
      y = ifelse(Mean>0 ,Mean + SE, Mean - SE)
    ), vjust = ifelse(summary_data$Mean > 0, -0.1, 1), size = 4) +
    labs(title = paste("ROI",roi_data$roi[1],roi_data$roi_name[1]), x = NULL , y = "Predicted Beta", colour = "black") +
    theme_pubr(x.text.angle = 45, base_size = 10)
  # geom_col(fill = '#8DD3C7', width = 0.8,color = "#424949") +  # Setting fill within aes
  #geom_bar(stat = "identity", fill = '#8DD3C7',width = 0.5,) +
  # geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), width = 0.25, position = position_dodge(0.9)) +
  
  #scale_y_continuous(expand = expansion(add = c(0, 0.1))) +
  #theme(plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))  # Adjust the margins as needed
  #p <- p + scale_y_continuous(limits = c(NA, max(summary_data$Mean + summary_data$SE)+0.1))
  
  # Print the plot
  print(p)
  # ggsave(paste("barROI",as.numeric(r), substr(file_path_sans_ext(data_psc$roi_name[as.numeric(r)]), 1, 20),".pdf" ,sep = "") ,path = 'barplotsMainConditions/'
  #        ,width = 3.4, height = 3, units = "in")
}


############# same plot as above only with three conditions
# 
# # bar plots of average of conditions 
# interests_toplot <- c('avg_bsl', 'avg_adap', 'avg_washout')
# 
# 
# for (r in unique(data_psc$roi)) {
#   roi_data <- subset(data_psc, roi == r)
#   #mean psc% over conditions
#   subset_cols_1 <- roi_data[, c("bsl1", "bsl2", "bsl3", "bsl4")]
#   subset_cols_2 <- roi_data[, c("rot5a", "rot5b","rot10a", "rot10b","rot15", "rot15run2","rot20a", "rot20b","rot25a", "rot25b","rot30a", "rot30b")]
#   subset_cols_3 <- roi_data[, c("Washout.1", "Washout.2", "Washout.3")]
#   
#   roi_data$avg_bsl <- rowMeans(subset_cols_1, na.rm = TRUE)
#   roi_data$avg_adap <- rowMeans(subset_cols_2, na.rm = TRUE)
#   roi_data$avg_washout <- rowMeans(subset_cols_3, na.rm = TRUE)  
#   # Create a data frame to store mean and standard error for each condition
#   summary_data <- data.frame(Condition = character(), Mean = numeric(), SE = numeric(), pvalue = numeric())
#   
#   plots <- list()
#   # Loop over pairs of variables
#   for (condition in interests_toplot) {
#     
#     condition_data <- roi_data[[condition]]
#     mean_value <- mean(condition_data, na.rm = TRUE)
#     se_value <- sd(condition_data, na.rm = TRUE) / sqrt(length(condition_data[!is.na(condition_data)]))
#     
#     stats <- t.test(condition_data, conf.level = 0.95)
#     summary_data <- rbind(summary_data, data.frame(Condition = condition, Mean = mean_value, SE = se_value, pvalue = stats$p.value))
#   }
#   
#   # make conditions as factor to be plotted in order
#   summary_data$Condition <- factor(summary_data$Condition, levels = interests_toplot)    
#   # Append to the summary data frame
#   
#   # Plot
#   p <- ggplot(summary_data, aes(x = Condition, y = Mean)) +
#     
#     geom_col(fill = '#8DD3C7', width = 0.8,color = "#424949") +  # Setting fill within aes
#     #geom_bar(stat = "identity", fill = '#8DD3C7',width = 0.5,) +
#     geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), width = 0.25, position = position_dodge(0.9)) +
#     #  geom_text(aes(label = ifelse(pvalue < 0.001, '***', ifelse(pvalue < 0.01, '**', ifelse(pvalue < 0.05, '*', 'n.s.')))), 
#     #           position = position_dodge(0.9), vjust = ifelse(summary_data$Mean>0, summary_data$Mean-summary_data$SE -5, summary_data$Mean-summary_data$SE+5) , size = 5) +
#     
#     geom_text(aes(
#       label = ifelse(pvalue < 0.001, '***', ifelse(pvalue < 0.01, '**', ifelse(pvalue < 0.05, '*', 'n.s.'))),
#       #y = max(summary_data$Mean) + 0.8 * (ifelse(summary_data$Mean > 0, 1, -1)) * (max(summary_data$Mean + summary_data$SE) - min(summary_data$Mean - summary_data$SE))
#       y = ifelse(Mean>0 ,Mean + SE, Mean - SE)
#     ), vjust = ifelse(summary_data$Mean > 0, -0.1, 1), size = 4) +
#     labs(title = paste("ROI", data_psc$roi_name[as.numeric(r)]), x = "Conditions", y = "PSC%", colour = "black") +
#     #scale_fill_manual(values = custom_colors) +
#     #scale_fill_manual(values = custom_colors)+
#     theme_pubr(x.text.angle = 45, base_size = 10)
#   #scale_y_continuous(expand = expansion(add = c(0, 0.1))) +
#   #theme(plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))  # Adjust the margins as needed
#   #p <- p + scale_y_continuous(limits = c(NA, max(summary_data$Mean + summary_data$SE)+0.1))
#   
#   # Print the plot
#   print(p)
# }

