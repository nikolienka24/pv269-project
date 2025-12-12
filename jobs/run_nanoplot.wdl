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

        # 1. FIX: Prevent OpenBLAS Threading Crash - uncomment when working on MetaCentrum
        # export OPENBLAS_NUM_THREADS=1
        # export OMP_NUM_THREADS=1
        # export MKL_NUM_THREADS=1

        # 2. FIX: Prevent Graphics/Display Crash - uncomment when working on MetaCentrum
        # export MPLBACKEND=Agg
        # export MPLCONFIGDIR=.
        # export XDG_CACHE_HOME=.

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

workflow RunNanoplot {
    input {
        Array[File] fastqs
        String out_dir = "assemblies.rdna"
        Int threads = 16
        String memory = "32 GB"
    }

    call RunNanoPlot {
        input:
            input_fastqs = fastqs,
            output_dir_name = out_dir,
            threads = threads,
            memory = memory
    }

    output {
        Array[File] full_results = RunNanoPlot.all_outputs
    }
}