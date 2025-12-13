version 1.0

# ================================================================
# TASK 1: Alignment
task RunAlignment {
    input {
        File assembly_fasta
        File reference_fasta
        Int threads = 8
        String memory = "24 GB"
    }

    command <<<
        set -euo pipefail

        # uncomment when working on MetaCentrum
        export OPENBLAS_NUM_THREADS=1
        export OMP_NUM_THREADS=1
        export MKL_NUM_THREADS=1

        echo "Starting minimap2 alignment..."
        minimap2 \
            -t ~{threads} \
            -c -x asm5 \
            ~{reference_fasta} \
            ~{assembly_fasta} > "wga_vs_rdna.paf"
    >>>

    output {
        File raw_paf = "wga_vs_rdna.paf"
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# TASK 2: Filtering

task FilterAlignments {
    input {
        File raw_paf
        Int min_alignment_length
        Float min_pident
        Int threads = 1
        String memory = "4 GB"
    }

    command <<<
        set -euo pipefail

        OUTPUT_FILTERED="wga_vs_rdna.filtered.paf"
        OUTPUT_IDS="rdna_contig_ids.txt"

        echo "Filtering PAF (Length >= ~{min_alignment_length}, Pct ID >= ~{min_pident}%)..."
        awk -v min_len=~{min_alignment_length} -v min_pid=~{min_pident} \
            '($11 >= min_len) && (($10/$11)*100 >= min_pid)' \
            ~{raw_paf} > "$OUTPUT_FILTERED"

        echo "Extracting unique contig IDs..."
        awk '{print $1}' "$OUTPUT_FILTERED" | sort -u > "$OUTPUT_IDS"
    >>>

    output {
        File filtered_paf = "wga_vs_rdna.filtered.paf"
        File contig_ids = "rdna_contig_ids.txt"
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# TASK 3: Extraction 
task ExtractSequences {
    input {
        File assembly_fasta
        File contig_ids_file
        Int threads = 4
        String memory = "16 GB"
    }

    command <<<
        set -euo pipefail

        # --- Symlink Setup ---
        # Samtools tries to write .fai index next to the input file.
        # Inputs are read-only, so we symlink it to the current folder first.
        ln -s ~{assembly_fasta} current_assembly.fasta

        OUTPUT_FASTA="rdna_positive_contigs.fasta"

        echo "Indexing assembly..."
        samtools faidx current_assembly.fasta

        echo "Extracting sequences..."
        samtools faidx current_assembly.fasta \
            -r ~{contig_ids_file} \
            -o "$OUTPUT_FASTA"
    >>>

    output {
        File final_fasta = "rdna_positive_contigs.fasta"
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# WORKFLOW DEFINITION
# ================================================================
workflow ExtractRDNA {
    input {
        File input_assembly
        File input_reference
        Int min_len = 40000
        Float min_pid = 85.0

        # Resources for the heavy alignment step
        Int alignment_threads = 32
        String alignment_memory = "128 GB"
    }

    call RunAlignment {
        input:
            assembly_fasta = input_assembly,
            reference_fasta = input_reference,
            threads = alignment_threads,
            memory = alignment_memory
    }

    call FilterAlignments {
        input:
            raw_paf = RunAlignment.raw_paf,
            min_alignment_length = min_len,
            min_pident = min_pid
    }

    call ExtractSequences {
        input:
            assembly_fasta = input_assembly,
            contig_ids_file = FilterAlignments.contig_ids
    }

    output {
        File alignment_paf = RunAlignment.raw_paf
        File filtered_paf = FilterAlignments.filtered_paf
        File contig_ids = FilterAlignments.contig_ids
        File final_fasta = ExtractSequences.final_fasta
    }
}