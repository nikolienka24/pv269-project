version 1.0

# ================================================================
# TASK: Filter FASTA by Length

task FilterByLength {
    input {
        File input_fasta
        Int min_length = 0

        Int threads = 2
        String memory = "4 GB"
    }

    command <<<
        set -euo pipefail

        seqkit seq \
            -m ~{min_length} \
            ~{input_fasta} > "filtered_min.~{min_length}.fasta"
    >>>

    output {
        File filtered_fasta = glob("filtered_min.*.fasta")[0]
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
    
    File blacklist_file = write_lines(contig_names_to_remove) # write each contig name on separate line

    command <<<
        set -euo pipefail

        ln -sf ~{input_fasta} current.fasta
        
        OUTPUT_FILE="filtered.fasta"

        # Generate the "whitelist"
        samtools faidx current.fasta
        cut -f1 current.fasta.fai > all_names.txt       
        if [ -s ~{blacklist_file} ]; then
            grep -v -x -F -f ~{blacklist_file} all_names.txt > whitelist.txt
        else
            cp all_names.txt whitelist.txt
        fi

        # Extract
        samtools faidx current.fasta \
            -r whitelist.txt \
            -o "$OUTPUT_FILE"
    >>>

    output {
        File filtered_fasta = "filtered.fasta"
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
        Array[String] contigs_to_remove
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
            contig_names_to_remove = contigs_to_remove
    }

    output {
        File result_fasta = RemoveContigsByName.filtered_fasta
    }
}