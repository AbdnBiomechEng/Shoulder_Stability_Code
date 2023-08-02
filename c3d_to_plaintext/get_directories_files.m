function [main_data_dir, participant_dirs, trial_nums, MVCtrial_nums] = get_directories_files

% get data
main_data_dir = '';

% five subjects
participant_dirs = {'ND201','ne60','ne701','nf001','nf501'};

% kinematic data trial numbers for each participant
trial_nums{1} = 22:41;
trial_nums{2} = [114, 21:43];  
trial_nums{3} = 21:48;
trial_nums{4} = [15 22:47];
trial_nums{5} = [20:38,40:52]; 

% MVC trial numbers for each participant
MVCtrial_nums{1} = [1 3:14];
MVCtrial_nums{2} = 101:113;
MVCtrial_nums{3} = [1:10 13:16];
MVCtrial_nums{4} = [1:11 13:14];
MVCtrial_nums{5} = 1:13;
