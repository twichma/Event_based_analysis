
1. Function: ReorganizedData_Final 
This function is used to analyze data exported from the IDSP software. It works with time-series data or spontaneous conditions. If the analysis is a time series, set TS = 1; otherwise, set TS = 0.

The function combines relevant information from the _Spikes, _Raw, and _Denoised data exported in .csv format from the IDSP software. It creates a MATLAB variable named after the Inscopix recording.

For spontaneous conditions, the generated .mat file will contain a variable named Spontaneous.Accepted_Cells, where each row corresponds to an accepted cell. This variable includes the denoised data, timing, raw data, X and Y centroids, time of events, amplitude of events, number of events, and event rate.
For time-series data (spontaneous followed by a touchscreen task), a prompt will appear asking you to select the corresponding bhv2 file recorded in parallel with the calcium imaging. This bhv2 file contains all timing and performance data related to the touchscreen task. The calcium imaging recording and touchscreen data will be realigned using the GPIO file, which contains the TTL pulse timing for task start and reward signals sent from the touchscreen to the calcium imaging system.
In addition to Spontaneous.Accepted_Cells, the .mat file will also contain:
TouchScreen.Accepted_Cells
behData

This function calls ISI_Final to calculate CV for spike event, mlbhv2 and mlread for behavioral data analysis and uses offset_GPIO_bhv2_v2 and extract_code_timing_Final to synchronize data from the bhv2 file with the calcium imaging recording.

2. Function: CellmapFinal
This function generates heatmaps based on raw data for the cells listed in the Metadata_all_Monkey database, created by AC and Damien. The monkey's name, recording side, and alignment can be modified in the variable section.

This program only analyzes cells that:

Were recorded with a corresponding GPIO file (for alignment with the behavioral task).
Were recorded for the first occurrence of the cells.
Data will be Z-scored using the second between each trial, and statistical analysis will compare data one second before and one second after the selected event (start of the trial or reward). 
A signed rank test will be used for statistical analysis.

Data for each trial will be stored in the TT variable.
p-values will be stored in ReOrder_p(1-3).
The activity ratio (indicating whether a cell's activity increased or decreased) will be stored in ReOrder_ratio(1-3).
The corresponding cell names will be stored in ReOrderGlobalID.

3.To perform the FDR correction on the p values, use the FDR_correction.m file. It will read a excel file exytact the column with p values and calculate the new p values FDR corrected.