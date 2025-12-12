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

        cd /auto/brno2/home/nikolpolakovaa/pv269-project/apps/ModDotPlot/
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