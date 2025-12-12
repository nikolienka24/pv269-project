version 1.0

# ================================================================
# TASK 1: Quast.py analysis
task RunQuast {
    input {
        # Array allows you to pass multiple assemblies to compare
        Array[File] assemblies
        String output_dir_name = "quast_output"
        Int threads = 16
        String memory = "32 GB"
    }

    command <<<
        set -euo pipefail

        # Running QUAST
        quast.py \
            ~{sep=' ' assemblies} \
            -o ~{output_dir_name} \
            --threads ~{threads}
    >>>

    output {
        Array[File] all_outputs = glob("~{output_dir_name}/*")
    }

    runtime {
        cpu: threads
        memory: memory
    }
}

# ================================================================
# WORKFLOW DEFINITION

workflow QuastAnalysis {
    input {
        Array[File] input_assemblies
        String out_dir = "assemblies.comparison"
    }

    call RunQuast {
        input:
            assemblies = input_assemblies,
            output_dir_name = out_dir
    }

    output {
        Array[File] full_results = RunQuast.all_outputs
    }
}
