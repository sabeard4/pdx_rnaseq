#!/bin/bash
#SBATCH --job-name=htseq-array
#SBATCH --output=output/htseq_%A_%a.out
#SBATCH --error=error/htseq_%A_%a.err
#SBATCH --array=1-144  # Replace <number_of_jobs> with the number of BAM files
#SBATCH --time=3:00:00        # Replace <time_limit> with your desired time limit
#SBATCH --cpus-per-task=1 # Replace <num_cpus> with the number of CPU cores you need
#SBATCH --mem=500M             # Replace <memory> with the required memory (e.g., 8G, 16G, etc.)

# Load necessary modules and activate the Conda environment
module purge
module load micromamba
eval "$(micromamba shell hook --shell bash)"
micromamba activate /htseq

# Define input files (adjust file paths as needed)

input_dir="/bam_files"

# Get the list of input files
bam_files=($input_dir/*.bam)

# Set the annotation GTF file
annotation_gtf="gencode.v44.primary_assembly.annotation.gtf.gz"

# Set the output directory
output_dir="/counts"

# Set the strand
strand="reverse"

# Extract the current BAM file to process
current_bam="${bam_files[$SLURM_ARRAY_TASK_ID - 1]}"

# Generate a unique output filename
output_filename="${output_dir}/$(basename ${current_bam} .bam).reverse_counts"

# Run htseq-count for the current BAM file
htseq-count --stranded=${strand} --type=exon --format=bam ${current_bam} ${annotation_gtf} > ${output_filename}

echo "Finished processing ${current_bam}"

# End of script

