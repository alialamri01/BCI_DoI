#!/bin/bash

#SBATCH --job-name={{STIMULATION_AMPLITUTE}}uA_{{STIMULATION_FREQUENCY}}Hz
#SBATCH --output=/project/nicho/projects/ali/cortical_stimulation_ampFreq2/main/{{LAYER_NAME}}/{{STIMULATION_AMPLITUTE}}uA_{{STIMULATION_FREQUENCY}}Hz/output_%a.out
#SBATCH --error=/project/nicho/projects/ali/cortical_stimulation_ampFreq2/main/{{LAYER_NAME}}/{{STIMULATION_AMPLITUTE}}uA_{{STIMULATION_FREQUENCY}}Hz/error_%a.err
#SBATCH --time=1:00:00
#SBATCH --partition=amd
#SBATCH --ntasks=500
#SBATCH --array=1-25
#SBATCH --mem=20G
#SBATCH --account=pi-nicho
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ahalamri@rcc.uchicago.edu

mpirun -np $SLURM_NTASKS ./mechanisms/x86_64/special -NSTACK 100000 -NFRAME 20000 -Py_NoSiteFlag -nobanner -c -mpi "cell_id=$SLURM_ARRAY_TASK_ID" init_icms.hoc

echo "All simulations completed."
