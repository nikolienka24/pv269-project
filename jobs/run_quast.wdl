version 1.0

# ================================================================
# TASK 1: Quast.py analysis
task RunQuast {
    input {
        Array[File] assemblies
        String output_dir_name = "quast_output"
        Int threads
        String memory
    }

    command <<<
        set -euo pipefail

        quast.py \
            ~{sep=' ' assemblies} \
            -o ~{output_dir_name} \
            --threads ~{threads}
    >>>

    output { }

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
        String out_dir = "quast_output"
        Int threads = 4
        String memory = "8 GB"
    }

    call RunQuast {
        input:
            assemblies = input_assemblies,
            output_dir_name = out_dir,
            threads = threads,
            memory = memory
    }

    output {}
}
