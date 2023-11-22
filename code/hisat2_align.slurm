#!/bin/bash
#SBATCH --job-name=hisat2_align
#SBATCH --array=1-72
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8  # Number of CPU cores per task
#SBATCH --mem=16G  # Memory per task
#SBATCH --time=2:00:00  # Adjust as needed
#SBATCH --output=output/hisat2_%A_%a.out
#SBATCH --error=error/hisat2_%A_%a.err

# Load HISAT2 module (adjust to your system)
module load hisat2/2.2.1
module load samtools/1.9

# Define input files (adjust file paths as needed)
input_dir="/fastq_files/"
output_dir="/bam_files/"
reference_genome="/GRCh38.v44.tran.index/genome_tran"

# Get the list of input files
files=($input_dir/*_R1.fastq.gz)

# Extract the current input files
input_file="${files[$SLURM_ARRAY_TASK_ID - 1]}"
base_name=$(basename "$input_file" _R1.fastq.gz)
read1="$input_file"
read2="$input_dir/${base_name}_R2.fastq.gz"

# HISAT2 alignment piped to SAMTOOLS for sorting and indexing
hisat2 -p $SLURM_CPUS_PER_TASK -x $reference_genome -1 $read1 -2 $read2 | \
    samtools view -@ $SLURM_CPUS_PER_TASK -bS - | \
    samtools sort -@ $SLURM_CPUS_PER_TASK -o "$output_dir/${base_name}_sorted.bam" -

# Index the sorted BAM file
samtools index -@ $SLURM_CPUS_PER_TASK "$output_dir/${base_name}_sorted.bam"

echo "$input_file job finished on $(date)"






