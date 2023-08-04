function save_pole_forces

% Prepare data for DAS3 (Opensim and realtime)

[main_data_dir, participant_dirs, trial_nums, ~] = get_directories_files;

% trials where the force pole was held the other way around
bforce{1} = [];
bforce{2} = [];
bforce{3} = 44:46;
bforce{4} = [42 45:47];
bforce{5} = [39 43:45 47:49];

for isub = 1:5
    
    outpath = ['kin_force_files\S' num2str(isub)];
    if ~exist(outpath, 'dir'), mkdir(outpath); end
    
    for ifile=trial_nums{isub}
        
        filename = [main_data_dir participant_dirs{isub} num2str(ifile)];
        [~,name,~] = fileparts(filename);
        data = btk_loadc3d([filename '.c3d']);
                
        % get hand forces, if they exist
        if isfield(data, 'force_data')
            
            handF = data.force_data.forces.ForceAG;
            % somehow between S1 and the rest, the force extraction has
            % changed...
            if isub~=1, handF = -handF; end
            
            % in some trials, the force sensors was held the other way
            % around
            if ismember(ifile,bforce{isub}), handF = -handF; end
                        
            % remove baseline force
            baseline = mean(handF(1:10,:));
            handF = handF - repmat(baseline,size(handF,1),1);
            
            time_vec = data.marker_data.Time;
            
            force_table = table;
            force_table.time = time_vec;
            force_table = [force_table array2table(handF,'VariableNames',{'x','y','z'})];
            handF_file = [outpath '\' name '_handF.csv'];
            writetable(force_table,handF_file);
            disp(['File ' handF_file ' created...']);
            
            handF_mot_file = [outpath '\' name '_handF.mot'];
            make_force_mot(handF_mot_file,-handF,time_vec); % forces *to* the hand
            disp(['File ' handF_mot_file ' created...']);
        end        
    end
    
    disp(['Finished subject ' num2str(isub)]);

end