#!/bin/bash 
#SBATCH -N 1 # Request 1 node
##SBATCH --exclusive
#SBATCH -n 4 #Request 4 tasks (cores)
#SBATCH -t 0-12:00 #Request max runtime of 12 hrs
#SBATCH -p sched_mit_hill #Run on specified partition
#SBATCH --mem-per-cpu=4000 #Request 4GB of memory per CPU
##SBATCH -o /pool001/${USER}/slurm/output_%j.txt #redirect output to output_JOBID.txt
##SBATCH -e /pool001/${USER}/slurm/error_%j.txt #redirect errors to error_JOBID.txt
##SBATCH --mail-type=BEGIN,END
##SBATCH --mail-user=${USER}@mit.edu

# Load modules
# module load anaconda3/2021.11
module load jdk/18.0.1.1
module load singularity/3.7.0

# Install Nextflow and add to your path
curl -s https://get.nextflow.io | bash
mkdir -p ~/bin && mv nextflow ~/bin
PATH=~/bin:$PATH

# Define vars
SINGULARITY_CACHEDIR=~/.singularity
SINGULARITY_TMPDIR=/tmp
NXF_SINGULARITY_CACHEDIR=/home/${USER}/.singularity

# Activate conda env
# conda create --name nf-core -c conda-forge -c bioconda python=3.7 nf-core nextflow
# source /home/software/anaconda3/2021.11/etc/profile.d/conda.sh
# conda activate nf-core

# Download Singularity images
# This should be handled automatically - if its not run this interactively
# nf-core download

# Test mag
# nextflow run main.nf --outdir results_test -profile test,engaging -resume

# Run mag on all Rothman HTP samples
# nextflow run main.nf -params-file params/rothman_htp.json -profile engaging -resume

# Run mag on the initial Illumina samples
# nextflow run main.nf -params-file params/illumina.json -profile engaging -resume