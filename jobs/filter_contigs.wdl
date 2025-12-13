version 1.0

# ================================================================
# TASK: Filter FASTA by Length

task FilterByLength {
    input {
        File input_fasta
        Int min_length = 12500

        Int threads = 2
        String memory = "4 GB"
    }

    command <<<
        set -euo pipefail

        # uncomment when working on MetaCentrum (MetaCentrum Configuration)
        # export OPENBLAS_NUM_THREADS=1
        # export OMP_NUM_THREADS=1
        # export MKL_NUM_THREADS=1
        # export MPLBACKEND=Agg
        # export MPLCONFIGDIR=.
        # export XDG_CACHE_HOME=.

        OUTPUT_FILE="filtered_min~{min_length}.fasta"

        echo "Filtering sequences >= ~{min_length} bp..."
        seqkit seq \
            -m ~{min_length} \
            ~{input_fasta} > "$OUTPUT_FILE"

        echo "Done. Saved to $OUTPUT_FILE"
    >>>

    output {
        File filtered_fasta = glob("filtered_min*.fasta")[0]
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

task RemoveContigsByName {
    input {
        File input_fasta
        Array[String] contig_names_to_remove
        
        Int threads = 2
        String memory = "4 GB"
    }

    command <<<
        set -euo pipefail

        # Symlink input because samtools needs to create .fai index next to it
        ln -s ~{input_fasta} current.fasta
        
        # Write the array of bad names to a file (blacklist)
        printf "%s\n" ~{sep="\n" contig_names_to_remove} > blacklist.txt

        OUTPUT_FILE="filtered_cleaned.fasta"

        # Generate the "whitelist"
        samtools faidx current.fasta
        cut -f1 current.fasta.fai > all_names.txt
        
        # Filter: All Names MINUS blacklist = whitelist
        grep -v -x -F -f blacklist.txt all_names.txt > whitelist.txt

        # --- 4. Extract ---
        samtools faidx current.fasta \
            -r whitelist.txt \
            -o "$OUTPUT_FILE"
    >>>

    output {
        File filtered_fasta = "filtered_cleaned.fasta"
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# WORKFLOW DEFINITION

workflow FilterAssembly {
    input {
        File assembly
        Int min_len_threshold = 0
        Array[String] bad_contigs
        Int threads = 1
        String memory = "8 GB"
    }

    call FilterByLength {
        input:
            input_fasta = assembly,
            min_length = min_len_threshold
    }

    call RemoveContigsByName {
        input:
            input_fasta = FilterByLength.filtered_fasta,
            contig_names_to_remove = bad_contigs
    }

    output {
        File result_fasta = RemoveContigsByName.filtered_fasta
    }
}