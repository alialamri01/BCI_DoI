#!/bin/bash
#SBATCH --job-name=run_all_layers
#SBATCH --output=master_output.log
#SBATCH --error=master_error.log
#SBATCH --time=24:00:00
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks=1

# Base directory for all layers
BASE_DIR="/path/to/generatedStimModel"

# Define ranges for amplitudes and frequencies
AMPLITUDES=(10 20 40 60 80)
FREQUENCIES=(50 100 150 200 250)
LAYERS=("Layer1" "Layer2_3" "Layer4" "Layer5" "Layer6")

# Loop through each layer, amplitude, and frequency combination
for LAYER in "${LAYERS[@]}"; do
    for AMP in "${AMPLITUDES[@]}"; do
        for FREQ in "${FREQUENCIES[@]}"; do
            # Construct the folder path
            FOLDER="$BASE_DIR/$LAYER/${AMP}uA_${FREQ}Hz"

            # Change to the mechanisms folder and compile
            if [ -d "$FOLDER/mechanisms" ]; then
                echo "Compiling mechanisms for $LAYER, $AMP uA, $FREQ Hz"
                cd "$FOLDER/mechanisms" || exit
                nrnivmodl
            else
                echo "Mechanisms folder not found for $FOLDER"
                continue
            fi

            # Change back to the main folder and submit the job
            cd "$FOLDER" || exit
            if [ -f "run_model_alamri_lean.sbatch" ]; then
                echo "Submitting job for $LAYER, $AMP uA, $FREQ Hz"
                sbatch run_model_alamri_lean.sbatch
            else
                echo "SBATCH file not found for $FOLDER"
            fi
        done
    done
done
