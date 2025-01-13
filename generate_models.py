"""
Script Name: generate_layer_stimulation_folders.py
Author: Ali Alamri 
Contact: ahalamri@uchicago.edu
Created: 2024-12-29
Last Updated: 2024-12-29

Description: 
    This script generates simulation configuration files for cortical column models.
    It loops over combinations of layers, stimulation amplitudes, and frequencies,
    creating unique folders and modifying `.sbatch` and `.hoc` template files with
    the specified parameters. This uses as a template an altered version of the model
    used by Karthik Kumaravelu et al. 2022 (PMID: 34861412)

Inputs:
    - Template directory (`templateStimModel`): Contains `.sbatch` and `.hoc` templates
      and other required files, which can be found in the files tab of this model at
      modeldb (https://modeldb.science/267691?tab=2)
    - Layers with depths or heights: Defined in the `layers` dictionary. Refer to Kumaravelu et al. 
      for the logic behind the layer depths and definitions. 
    - Amplitudes: List of stimulation amplitudes in microamperes.
    - Frequencies: List of stimulation frequencies in Hertz.

Outputs:
    - A directory (`generatedModels`) containing subdirectories for each
      layer which contains subdirectories for each parameter combination model.
      Each subdirectory includes:
        - Modified `.sbatch` file
        - Modified `.hoc` file
        - Other files copied from the template directory.

Usage:
    1. Define layer depths or heights, amplitudes, and frequencies in the script.
    2. Run the script in a Python 3 environment.
    3. Generated files are saved in the `generatedModels` directory.

Notes:
    - Ensure template placeholders (`{{STIMULATION_AMPLITUTE}}`, `{{STIMULATION_FREQUENCY}}`, 
      `{{LAYER_DEPTH}}`) are correctly defined in the `.sbatch` and `.hoc` templates.
    - Check file paths and permissions before running.

"""

import os
import shutil

#define ranges for amplitude, frequency, and corrected layer heights
amplitudes = [10, 20, 40, 60, 80]
frequencies = [50, 100, 150, 200, 250]
layers = {
    "Layer1": 1875,   
    "Layer2_3": 1438,
    "Layer5": 563
}

#template folder
template_folder = "./templateStimModel"
output_dir_name = "generatedStimModel"

#template file namese
sbatch_template_name = "run_model_alamri.sbatch"
hoc_template_name = "init_icms.hoc"

full_output_dir = os.path.join(os.getcwd(), output_dir_name)

#ensure the output base directory exists
os.makedirs(full_output_dir, exist_ok=True)

for layer_name, depth in layers.items():
    
    layer_folder = os.path.join(full_output_dir, layer_name)

    print(layer_name)
    print(depth)

    for amp in amplitudes:
        for freq in frequencies:
            #create a new folder for this parameter combination
            folder_name = f"{amp}uA_{freq}Hz"
            output_folder = os.path.join(full_output_dir, layer_folder, folder_name)
            os.makedirs(output_folder, exist_ok=True)

            #copy the entire template folder into the new folder
            shutil.copytree(template_folder, output_folder, dirs_exist_ok=True)

            #modify the `.sbatch` file
            sbatch_path = os.path.join(output_folder, sbatch_template_name)
            if os.path.exists(sbatch_path):
                with open(sbatch_path, 'r') as sbatch_file:
                    sbatch_content = sbatch_file.read()
                sbatch_modified = (
                    sbatch_content.replace("{{STIMULATION_AMPLITUTE}}", str(amp))
                                .replace("{{STIMULATION_FREQUENCY}}", str(freq))
                                .replace("{{LAYER_NAME}}", str(layer_name))
                )
                with open(sbatch_path, 'w') as sbatch_file:
                    sbatch_file.write(sbatch_modified)

            #modify the `.hoc` file
            hoc_path = os.path.join(output_folder, hoc_template_name)
            if os.path.exists(hoc_path):
                with open(hoc_path, 'r') as hoc_file:
                    hoc_content = hoc_file.read()
                hoc_modified = (
                    hoc_content.replace("{{STIMULATION_AMPLITUTE}}", str(amp))
                            .replace("{{STIMULATION_FREQUENCY}}", str(freq))
                            .replace("{{LAYER_DEPTH}}", str(depth))
                )
                with open(hoc_path, 'w') as hoc_file:
                    hoc_file.write(hoc_modified)

            print(f"Generated folder: {amp}uA_{freq}Hz with updated files.")
