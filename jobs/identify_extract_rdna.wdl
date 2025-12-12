version 1.0

# ================================================================
# TASK 1: Identify Reads using Minimap2
task IdentifyRdnaReads {
    input {
        File rdna_reference
        File dataset
        Int min_alignment_score = 3000
        Int threads = 32
        String minimap2_preset = "map-ont"
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
        memory: "64 GB"
    }
}

# ================================================================
# TASK 2: Extract Reads using IDs

task ExtractReads {
    input {
        File dataset
        File read_ids
        String result_extracted_rdna_reads = "rdna_reads.fastq"
        Int threads
    }

    command <<<
        set -euo pipefail

        echo "Extracting matching reads..."

        # Extract reads
        seqtk subseq "~{dataset}" "~{read_ids}" > "~{result_extracted_rdna_reads}"
    >>>

    output {
        File extracted_reads_fastq = result_extracted_rdna_reads
    }

    runtime {
        # Now this works because 'threads' is in the input block above
        cpu: threads
        memory: "32 GB"
    }
}

# ================================================================
# WORKFLOW DEFINITION

workflow IdentifyExtractrDNA {
    input {
        File rdna_reference
        File dataset
        Int alignment_score_threshold = 3000
        Int num_threads = 32
    }

    call IdentifyRdnaReads {
        input:
            rdna_reference = rdna_reference,
            dataset = dataset,
            min_alignment_score = alignment_score_threshold,
            threads = num_threads
    }

    call ExtractReads {
        input:
            dataset = dataset,
            read_ids = IdentifyRdnaReads.rdna_read_ids,
            # FIX 2: Passed the workflow variable 'num_threads' to the task input 'threads'
            threads = num_threads
    }

    output {
        File identified_read_ids = IdentifyRdnaReads.rdna_read_ids
        File extracted_reads_fastq = ExtractReads.extracted_reads_fastq
    }
}