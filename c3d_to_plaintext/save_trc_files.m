function save_trc_files
% Prepare kinematic data for DAS3 (Opensim and realtime)

[main_data_dir, participant_dirs, trial_nums, ~] = get_directories_files;

% save trc files
for isub=1:5
    for ifile=trial_nums{isub}
        filename = [main_data_dir participant_dirs{isub} num2str(ifile)];
        disp(['Analyzing trial ' filename]);
        outpath = ['kin_force_files\S' num2str(isub)];
        if ~exist(outpath, 'dir'), mkdir(outpath); end
        build_trc_file([filename '.c3d'],outpath);
    end
end

