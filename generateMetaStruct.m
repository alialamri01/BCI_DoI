%get the main directory to return to
main_dir = '/project/nicho/projects/ali/cortical_stimulation_ampFreq2/main/completed';
cd(main_dir)

%main folders to iterate over representing cortical layers to process 
layers = {'L1', 'L2_3', 'L4', 'L5', 'L6'};
electrode_depths = [1875, 1437, 1000, 562, 125];

%initialize the metaStruct
modelMetaStruct = struct();
modelMetaStruct.data = struct();

%counter to iterate over all layers and stim combinations 
counter = 1;

%loop through all of the layers
for l = 1:length(layers)

    layer_folder = layers{l};
    fprintf('Processing layer folder: %s\n', layer_folder);

    %get list of subfolders in the current layer folder 
    subfolders = dir(fullfile(layer_folder, '*'));
    subfolders = subfolders(3:end, :); %get rid of the '.' and the '..' folders 

    %loop through all of the subfolders 
    for s = 1:length(subfolders)
        
        subfolder_path = fullfile(subfolders(s).folder, subfolders(s).name);
        fprintf('   Processing subfolder: %s\n', fullfile(layer_folder, subfolders(s).name));

        %get the amp and frequency combo for this folder 
        amp_freq = strsplit(subfolders(s).name, '_');

        amp = amp_freq{1};
        freq = amp_freq{2};

        %get the path to the data analysis folder 
        data_analysis_folder = fullfile(subfolder_path, 'data_analysis');

        try
            
            cd(data_analysis_folder)

            %soma processing code
            clearvars -except main_dir electrode_depths layers layer_folder l subfolders s amp freq modelMetaStruct counter
            close all
            
            % Load necessary data
            load('realx.dat')
            load('realy.dat')
            load('realz.dat')
            load('cell_cnt.dat')
            
            % Electrode tip coordinates
            elec_x = 200;
            elec_y = electrode_depths(l);
            elec_z = 200;
            
            % Initialize cell array to store spike times
            data = {}; 
            
            % Loop through each cell id and concatenate the spike times into a neurons x spikeTimes structure
            for id = 1:25
                loaded_data = load(['data_soma' num2str(id) '.mat']);
                data = [data; squeeze(struct2cell(loaded_data.data_soma))];
            end 
            
            % Number of neurons
            num_neurons = length(data);
            
            % Initialize array to store distances
            distances = zeros(num_neurons, 1);
            activations = zeros(num_neurons, 1);  % 1 if activated, 0 otherwise
            
            % Calculate the distance of each neuron from the electrode tip and check for activation
            neuron_idx = 1;
            for id = 1:25
                for k = 1:cell_cnt(id)
                    % Calculate the distance from the electrode tip
                    x_coord = realx(sum(cell_cnt(1:id)) - cell_cnt(id) + k);
                    y_coord = realy(sum(cell_cnt(1:id)) - cell_cnt(id) + k);
                    z_coord = realz(sum(cell_cnt(1:id)) - cell_cnt(id) + k);
                    
                    distances(neuron_idx) = sqrt((x_coord - elec_x)^2 + (y_coord - elec_y)^2 + (z_coord - elec_z)^2);
                    
                    % Check if the neuron was activated (at least one spike)
                    if ~isempty(data{neuron_idx})
                        activations(neuron_idx) = 1;  % Mark as activated
                    else
                        activations(neuron_idx) = 0;  % Mark as not activated
                    end
                    
                    neuron_idx = neuron_idx + 1;
                end

            end

            fprintf('   Successfully processed subfolder.\n');
        
        catch ME
            %catch the error and display them without stopping the loop 
            fprintf('   Error in subfolder %s: %s\n', subfolder_path, ME.message);
        end

        %add all relevant information to the metastructure
        modelMetaStruct.data(counter).layer       = layer_folder;
        modelMetaStruct.data(counter).amp         = amp;
        modelMetaStruct.data(counter).freq        = freq;
        modelMetaStruct.data(counter).spikeTimes  = data;
        modelMetaStruct.data(counter).activated   = activations;

        counter = counter + 1;

    end
    
    %the distances from the electrode only change per layer so save them
    %seperately after every layer
    modelMetaStruct.distanceFromElectrode(l).layer     = layer_folder;
    modelMetaStruct.distanceFromElectrode(l).distances = distances; 


    %once you've looped through all of the subfolders, return to the main
    %dir
    cd(main_dir)

end 

%save a single instance of the neuron coordinates and electrode depths
modelMetaStruct.cellCoordinates.x  = realx;
modelMetaStruct.cellCoordinates.y  = realy;
modelMetaStruct.cellCoordinates.z  = realz;

modelMetaStruct.electrodeDepths    = electrode_depths;

fprintf('All layers processed.\n')

%% add a readme to the structure 

readMe = sprintf(['*data -- contains a structure which is n_layers x n_amps x n_freq long.\n', ...
                  '  -spikeTimes:  contains an array of spike times for each neuron\n', ...
                  '  -activated:   indicates whether the neuron was activated or not\n\n', ...
                  '*distanceFromElectrode -- pretty self explanatory. The linear distance of each neuron\n', ...
                  '                          from the tip of the stimulating electrode for each layer.\n\n', ...
                  '*cellCoordinates -- the X, Y, and Z coordinates for each neuron.\n\n', ...
                  '*electrodeDepths -- the depth at which each electrode was placed.']);

modelMetaStruct.readMe      = readMe;
