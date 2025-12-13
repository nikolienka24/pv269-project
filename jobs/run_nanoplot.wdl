version 1.0

# ================================================================
# TASK 1: Nanoplot analysis
task RunNanoPlot {
    input {
        Array[File] input_fastqs
        String output_dir_name = "nanoplot_output"
        Int threads = 4
        String memory = "8 GB"
    }

    command <<<
        set -euo pipefail

        NanoPlot \
            --fastq ~{sep=' ' input_fastqs} \
            -o ~{output_dir_name} \
            -t ~{threads}
    >>>

    output { }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# WORKFLOW DEFINITION

workflow RunNanoplot {
    input {
        Array[File] fastqs
        String out_dir = "output_nanoplot"
        Int threads = 4
        String memory = "8 GB"
    }

    call RunNanoPlot {
        input:
            input_fastqs = fastqs,
            output_dir_name = out_dir,
            threads = threads,
            memory = memory
    }

    output { }
}