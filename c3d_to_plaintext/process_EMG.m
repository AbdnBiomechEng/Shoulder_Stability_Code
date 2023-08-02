function process_EMG
% Get EMG data from c3d files, normalise by MVC and find envelope

[main_data_dir, participant_dirs, trial_nums, MVCtrial_nums] = get_directories_files;

% EMG names
EMG_names = {'Biceps','Triceps Lo','Triceps La','Pectoralis','Trapezius U','Trapezius L',...
          'Deltoid A','Deltoid M','Deltoid P','Brachioradialis','Supraspinatus','Infraspinatus',...
          'Teres M','Brachialis','Triceps','Latissimus D'};

      
% number of EMGs for each subject
EMGnum = [14 14 14 14 14];

% filter parameters
filter_order = 4;                       
% highpass_freq = 15; % Hz
% lowpass_freq = 450; % Hz
envelope_freq = 4;  % Hz

for isub=1:5
    
    outpath = ['emg_files\S' num2str(isub)];
    if ~exist(outpath, 'dir'), mkdir(outpath); end
    maxEMG = [];
    
    % first look through all trials with maximum voluntary contractions (MVC)
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
        
        % get analog data
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

        if ~isempty(fieldnames(analogs))
            Vtemp = struct2cell(analogs);
            V = cell2mat(Vtemp');
            EMG = V(:,mus_index);
            
            % remove offset and rectify
            meanEMG = repmat(mean(EMG),size(EMG,1),1);
            EMG = EMG-meanEMG;
            rect_emg = abs(EMG); 
            
            % low-pass filter to get the envelope
            lfreq=envelope_freq/(sampling_freq/2);
            [D,C]=butter(filter_order,lfreq,'low');
            emg_envelope = filtfilt(D,C,rect_emg);   
            
            % save the max up to this point
            mEMG = max(emg_envelope);
            maxEMG = max([maxEMG; mEMG],[],1);
        else
            disp('No analog data found. Skipping file.');
        end        
        
    end
    
    % save MVC in matlab file
    save([outpath '\EMG_MVC'], 'maxEMG', 'MVCnames');
    
    % now save all dynamic trial EMG, processed and normalised to MVC
    for ifile=trial_nums{isub}
        filename = [main_data_dir participant_dirs{isub} num2str(ifile)];
        [~,name,~] = fileparts(filename);
        disp(['Analyzing trial ' filename]);
        data = btk_loadc3d([filename '.c3d']);
        
        % get analog data
        analogs = data.analog_data.Channels;
        analogsInfo = data.analog_data.Info;
        
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
        
        % remove offset and rectify
        sampling_freq = data.analog_data.Info.frequency;
        Vtemp = struct2cell(analogs);
        V = cell2mat(Vtemp');
        EMG = V(:,mus_index);
        meanEMG = repmat(mean(EMG),size(EMG,1),1);
        EMG = EMG-meanEMG;
        rect_emg = abs(EMG);
        
        % low-pass filter to get the envelope
        lfreq=envelope_freq/(sampling_freq/2);
        [D,C]=butter(filter_order,lfreq,'low');
        emg_envelope = filtfilt(D,C,rect_emg);       
                
        % normalise using MVC
        nEMG = emg_envelope./repmat(maxEMG,size(EMG,1),1);
               
        % resample to match kinematic frequency
        emg_t = data.analog_data.Time;
        new_t = data.marker_data.Time;
        proc_emg = interp1(emg_t,emg_envelope,new_t,'nearest','extrap');
        
        % save EMG in csv file        
        EMG_table = table;
        EMG_table.time = new_t;
        EMG_table = [EMG_table array2table(proc_emg,'VariableNames',matlab.lang.makeValidName(EMGnames_infile))];
        EMGfile = [outpath '\' name '.csv'];   
        writetable(EMG_table,EMGfile);
        disp(['File ' EMGfile ' created...']);        
     end
     disp(['Finished participant S' num2str(isub)]);

end
