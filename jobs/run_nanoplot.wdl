version 1.0

# ================================================================
# TASK 1: Nanoplot analysis
task RunNanoPlot {
    input {
        Array[File] input_fastqs
        String output_dir_name = "nanoplot_output"
        Int threads = 16
        String memory = "32 GB"
    }

    command <<<
        set -euo pipefail

        # Run NanoPlot
        NanoPlot \
            --fastq ~{sep=' ' input_fastqs} \
            -o ~{output_dir_name} \
            -t ~{threads}
    >>>

    output {
        # Capture everything else in the folder (images, stats)
        Array[File] all_outputs = glob("~{output_dir_name}/*")
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
        Array[File] fastqs
        String out_dir = "assemblies.rdna"
    }

    call RunNanoPlot {
        input:
            input_fastqs = fastqs,
            output_dir_name = out_dir
    }

    output {
        Array[File] full_results = RunNanoPlot.all_outputs
    }
}