version 1.0

# ================================================================
# TASK 1: Identify Reads using Minimap2
task IdentifyRdnaReads {
    input {
        File rdna_reference
        File dataset
        Int min_alignment_score = 3000
        Int threads = 8
        String memory = "16 GB"
        String minimap2_preset = ""
        String result_ids_file = "rdna_ids.txt"
    }

    command <<<
        set -euo pipefail

        # 1. Index reference
        minimap2 -d "~{rdna_reference}.mmi" "~{rdna_reference}"

        # 2. Map and filter
        minimap2 \
            -t ~{threads} -a -x ~{minimap2_preset} \
            -y --MD -Y \
            "~{rdna_reference}.mmi" \
            "~{dataset}" \
        | awk '
            BEGIN {FS="\t"; MIN_SCORE='"~{min_alignment_score}"'}
            !/^@/ {
                for (i=1; i<=NF; i++) {
                    if ($i ~ /^AS:i:/) {
                        split($i, as, ":")
                        if (as[3] >= MIN_SCORE) print $1
                        break
                    }
                }
            }
        ' > "~{result_ids_file}"

         # 3. Keep unique read IDs
         sort -u -o "~{result_ids_file}" "~{result_ids_file}"
    >>>

    output {
        File rdna_read_ids = result_ids_file
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# TASK 2: Extract Reads using IDs

task ExtractReads {
    input {
        File dataset
        File read_ids
        String result_extracted_rdna_reads = "rdna_reads.fastq"
        Int threads = 8
        String memory = "16 GB"
    }

    command <<<
        set -euo pipefail

        seqtk subseq "~{dataset}" "~{read_ids}" > "~{result_extracted_rdna_reads}"
    >>>

    output {
        File extracted_reads_fastq = result_extracted_rdna_reads
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# WORKFLOW DEFINITION

workflow IdentifyExtractrDNA {
    input {
        File rdna_reference
        File dataset
        Int alignment_score_threshold = 3000
        Int num_threads = 8
        String memory = "16 GB"
    }

    call IdentifyRdnaReads {
        input:
            rdna_reference = rdna_reference,
            dataset = dataset,
            min_alignment_score = alignment_score_threshold,
            threads = num_threads,
            memory = memory
    }

    call ExtractReads {
        input:
            dataset = dataset,
            read_ids = IdentifyRdnaReads.rdna_read_ids,
            threads = num_threads,
            memory = memory
    }

    output {
        File identified_read_ids = IdentifyRdnaReads.rdna_read_ids
        File extracted_reads_fastq = ExtractReads.extracted_reads_fastq
    }
}