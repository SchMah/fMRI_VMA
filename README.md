# 📂 fMRI_VMA

## 📖 Overview
This project contains code, and analyses related to **fMRI_MotorAdaptation_project**. The folder structure is shown below.
Due to privacy constraints associated with this project, the full project files and datasets are available upon request.
---
## 📁 Folder Structure 
```
fMRI_MotorAdaptation_project/

├── Experiment/
│   ├── fMRI_mainTask/
│   ├── fMRI_reach_localizer/  
├── analysis/ 
│   ├── analysis_behavioral/
│   │   ├── Matlab/
│   │   ├── R/
│   │   │   ├── Behavioral Analysis/
│   │   │   │   ├── AdaptationBlocks/
│   │   │   │   ├── KinematicParameters/
│   │   │   │   └── LocalizationTrials/
│   ├── analysis_fMRI/
│   │   ├── maintask/
│   │   │   ├── Preprocessing/
│   │   │   ├── BIDS/
│   │   │   ├── GLM1/
│   │   │   ├── GLM2/
│── README.md              
```

---
&nbsp;
&nbsp;


## **📖 Folder Descriptions**
### 📂 `code/`
- **Experiment/**  
  - `fMRI_mainTask/` → Contains scripts for the main session. `fMRI_visuomotor.m` runs the experiment.
  - `fMRI_reach_localizer/` → Includes scripts for the localizer task. `fMRI_reach_localizer.m` runs the task.
- **analysis/**
  - `analysis_behavioral/` → Behavioral data analysis scripts.
    - `Matlab/` → MATLAB scripts for behavioral analyses. `adap_catData` and `loc_catData` preprocess the individual datasets and append them to the main group dataset. `T_group.mat` and `T_GLoc.mat` are group data for adaptation blocks and localization trials, respectively. `main.m` is the main script for running the analysis and generating figures. `KinematicParameters.m` analyzes movement time and reaction time analysis.
    - `R/` → R scripts for statistical analyses related to behavioral performance.
      - `Behavioral Analysis/` 
        - `AdaptationBlocks/` → Scripts for adaptation block analysis.
        - `KinematicParameters/` → Statistical analysis of kinematic parameters.
        - `LocalizationTrials/` → Scripts for analyzing localization trials.
  - `analysis_fMRI`/ → Neuroimaging data processing and statistical analysis.
      - `maintask/` → Contains preprocessing, general linear model (GLM) specifications, and stats analysis for the second session (adaptation task).
          - `Preprocessing/` → Includes subfolders named `1_*`, `2_*`, and so on, each for a specific preprocessing step.
          -  `BIDS/` → Contains preprocessed data for each subject
          -  `GLM1/` → Contains four matlab scripts to specify the model, define contrasts of interest, and perform the second level analysis. Each step is defined by `step*` in the file name.
                - `Firstlevel/` → Stores first-level analysis results for individual subjects. 
                - `2ndlevel/` → Contains group analysis results for each contrast of interest.
                - `GLM1_stats/` → Additional MATLAB and R scripts for further analysis. `PlotPredictedBetas.m` extracts predicted beta values for each GLM predictor from regions of interests defined by the localizer task and saves them in `beta_adaptation_beh.txt` for further analysis in R. The matlab script containing ROIs can be found in the `MainTask/` folder. Script `Barplots_conditions` and `CorrelationPlots` perform analysis on extracted beta values and save the figures in two separate forlders. `Barplots_conditions` generates bar plots of predicted betas for each adaptation block. `CorrelationPlots` analyzes correlations between predicted betas and hand angles.
        - `GLM2/` → Has the same folder structure as `GLM1/`.
          - `GLM2_stats/` → `correlationPlots_perception.m` extracts beta values from the hand perception parametric modulator contrast and saves them in `beta_perception.txt`. The ROIs are the same as in GLM1 in `MainTask/regions_roi_localizer_thalamus`.            



---

- **Dependencies to use the code**
   - MATLAB R2019b (version used for data analysis)
   - R 2023.09.1
   - SPM12
     

