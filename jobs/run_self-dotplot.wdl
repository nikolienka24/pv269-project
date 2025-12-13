version 1.0

# ================================================================
# TASK 1: ModDotPlot analysis
task RunModDotPlot {
    input {
        File input_fasta
        String output_folder_name
        Int threads = 1
        String memory = "8 GB"
    }

    command <<<
        set -euo pipefail

        moddotplot static \
            -f ~{input_fasta} \
            -o ~{output_folder_name}
    >>>

    output {}

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
        String out_folder_name = "output_dotplot"
    }

    call RunModDotPlot {
        input:
            input_fasta = fasta_file,
            output_folder_name = out_folder_name
    }

    output {}
}