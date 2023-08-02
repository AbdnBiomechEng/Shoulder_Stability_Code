function save_EMG_files
% Get EMG data from c3d files and save into csv files

[main_data_dir, participant_dirs, trial_nums, MVCtrial_nums] = get_directories_files;

% EMG names
EMG_names = {'Biceps','Triceps Lo','Triceps La','Pectoralis','Trapezius U','Trapezius L',...
          'Deltoid A','Deltoid M','Deltoid P','Brachioradialis','Supraspinatus','Infraspinatus',...
          'Teres M','Brachialis','Triceps','Latissimus D'};

      
% number of EMGs for each subject
EMGnum = [14 14 14 14 14];


for isub=1:5
    
    outpath = ['emg_files\S' num2str(isub)];
    if ~exist(outpath, 'dir'), mkdir(outpath); end
    
    % first save all trials with maximum voluntary contractions (MVC)
    for ifile=MVCtrial_nums{isub}
        
        if ifile<10 && isub~=2  % this is to get the filenames right
            filename = [main_data_dir participant_dirs{isub}, '0', num2str(ifile)];
            disp(['Analyzing MVC trial ' filename]);
            acq = btkReadAcquisition([filename, '.c3d']);
        else
            filename = [main_data_dir participant_dirs{isub} num2str(ifile)];
            disp(['Analyzing MVC trial ', filename]);
            acq = btkReadAcquisition([filename '.c3d']);
        end
        
        % get analog data and sampling frequency
        [analogs, analogsInfo] = btkGetAnalogs(acq);
        sampling_freq = analogsInfo.frequency;
        
        % find which muscle is which in the analog data
        index = 0;
        MVCnames = cell(EMGnum(isub),1);
        mus_index = zeros(EMGnum(isub),1);
        for imus=1:length(EMG_names)
            k = strfind(struct2cell(analogsInfo.label),EMG_names{imus});
            if find(~cellfun(@isempty,k))
                if length(find(~cellfun(@isempty,k)))==1
                    index = index+1;
                    MVCnames{index} = EMG_names{imus};
                    mus_index(index) = find(~cellfun(@isempty,k));
                end
            end
        end

        % put EMG data in table with a time column, and export to csv
        if ~isempty(fieldnames(analogs))
            Vtemp = struct2cell(analogs);
            V = cell2mat(Vtemp');
            EMG = V(:,mus_index);
            meanEMG = repmat(mean(EMG),size(EMG,1),1);
            EMG = EMG-meanEMG; % remove offset
            EMG_table = table;
            EMG_table.time = (1/sampling_freq)*(1:size(EMG,1))';
            EMG_table = [EMG_table array2table(EMG,'VariableNames',matlab.lang.makeValidName(MVCnames))];
            writetable(EMG_table, [outpath '\EMG_MVC' num2str(ifile) '.csv']);
                        
        else
            disp('No analog data found. Skipping file.');
        end        
        
    end
        
    % now do the same for all dynamic trials
    for ifile=trial_nums{isub}
        filename = [main_data_dir participant_dirs{isub} num2str(ifile)];
        [~,name,~] = fileparts(filename);
        disp(['Analyzing trial ' filename]);
        data = btk_loadc3d([filename '.c3d']);
        
        % get analog data and sampling frequency
        analogs = data.analog_data.Channels;
        analogsInfo = data.analog_data.Info;
        sampling_freq = data.analog_data.Info.frequency;
        
        % find which muscle is which in the analog data
        index = 0;
        EMGnames_infile = cell(EMGnum(isub),1);
        mus_index = zeros(EMGnum(isub),1);
        for imus=1:length(EMG_names)
            k = strfind(struct2cell(analogsInfo.label),EMG_names{imus});
            if find(~cellfun(@isempty,k))
                if length(find(~cellfun(@isempty,k)))==1
                    index = index+1;
                    EMGnames_infile{index} = EMG_names{imus};
                    mus_index(index) = find(~cellfun(@isempty,k));
                end
            end
        end        
                
        % put EMG data in table with a time column, and export to csv
        Vtemp = struct2cell(analogs);
        V = cell2mat(Vtemp');
        EMG = V(:,mus_index);
        meanEMG = repmat(mean(EMG),size(EMG,1),1);
        EMG = EMG-meanEMG; % remove offset
        
        EMG_table = table;
        EMG_table.time = (1/sampling_freq)*(1:size(EMG,1))';
        EMG_table = [EMG_table array2table(EMG,'VariableNames',matlab.lang.makeValidName(EMGnames_infile))];
        EMGfile = [outpath '\' name '.csv'];   
        writetable(EMG_table,EMGfile);
        disp(['File ' EMGfile ' created...']);        
     end
     disp(['Finished participant S' num2str(isub)]);

end
