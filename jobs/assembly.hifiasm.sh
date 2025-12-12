#!/bin/bash
#PBS -N assembly_rdna

#PBS -l select=1:ncpus=16:mem=128gb:scratch_local=1000gb
#PBS -l walltime=4:00:00

#PBS -j oe
#PBS -o /auto/brno2/home/nikolpolakovaa/pv269_local/project/logs/assembly_rdna.log

IN="<path_to_intput_fastq>"
OUT_DIR="<path_to_output_directory>"

hifiasm="<path_to_hifiasm_binary>"

mkdir -p "$OUT_DIR"
cd "$OUT_DIR" || exit 1

source /storage/praha5-elixir/projects/bioinf-fi/polakova/apps/miniconda3/etc/profile.d/conda.sh
conda activate /storage/liberec3-tul/home/nikolpolakovaa/.conda/envs/bioinf

echo "Started on $(date)"
"$hifiasm" -o ont_assembly -t 64 "$IN"
echo "Finished on $(date)"
