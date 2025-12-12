version 1.0

# ================================================================
# TASK 1: ModDotPlot analysis
task RunModDotPlot {
    input {
        File input_fasta
        String output_prefix = "output_dotplot"
        Int threads = 1
        String memory = "8 GB"
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

        moddotplot static \
            -f ~{input_fasta} \
            -o ~{output_prefix}
    >>>

    output {
        Array[File] all_outputs = glob("~{output_prefix}*")
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# WORKFLOW DEFINITION

workflow ModDotPlotAnalysis {
    input {
        File fasta_file
        String out_name = "output_dotplot"
    }

    call RunModDotPlot {
        input:
            input_fasta = fasta_file,
            output_prefix = out_name
    }

    output {
        Array[File] full_results = RunModDotPlot.all_outputs
    }
}