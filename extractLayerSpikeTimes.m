%% Script to extract all of the spikes from nested folders of models that were run

%main folders to iterate over representing cortical layers to process 
layers = {"L1", "L2_3", "L5"}; 

%loop through all of the layers
for l = "L5" %1:length(layers)
    
    layer_folder = l; %layers{l};
    fprintf('Processing layer folder: %s\n', layer_folder);

    %get list of subfolders in the current layer folder 
    subfolders = dir(fullfile(layer_folder, '*'));
    subfolders = subfolders(3:end, :); %get rid of the '.' and the '..' folders 

    %loop through all of the subfolders 
    for s = 1
        
        subfolder_path = fullfile(subfolders(s).folder, subfolders(s).name);
        fprintf('   Processing subfolder: %s\n', fullfile(layer_folder, subfolders(s).name));

        %get the path to the data analysis folder 
        data_analysis_folder = fullfile(subfolder_path, 'data_analysis');

        try
            
            cd(subfolder_path) %change from the home folder to the subfolder of interest 

            %load cell count data 
            if exist('cell_cnt.dat', 'file')
                load('cell_cnt.dat');
            else 
                warning('cell_cnt.dat not found in %s. Skipping...', subfolder_path);
                continue
            end

            for cell_type = 1:25
                
                cnt = 1;

                %initialize data structure
                data_soma = struct(); 

                for i=1:cell_cnt(cell_type)

                    %construct the name of the data file for the layer and
                    %neuron
                    name = sprintf('Vm_%d_%d.dat', cell_type, i);
                    
                    if exist(name, 'file')

                        a = load(name);
                        data_soma(cnt).times = a(diff(a(:,2)>-20)==1,1)';
                        cnt=cnt+1;
                        clear a

                    else 
                        warning('File %s not found in %s. Skipping...', name, subfolder_path);
                    end
                end 

                %save the data_soma file in the 'data_analysis' folder 
                name1 = fullfile(data_analysis_folder, sprintf('data_soma%d.mat', cell_type));
                save(name1, 'data_soma');
                fprintf('       Saved: data_soma%d.mat\n', cell_type);
                clear data_soma name1;

            end

            fprintf('   Successfully processed subfolder: %s\n', subfolder_path);
        
        catch ME
            %catch the error and display them without stopping the loop 
            fprintf('   Error in subfolder %s: %s\n', subfolder_path, ME.message);
        end 

    end

end 

fprintf('All layers processed.\n')