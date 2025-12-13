# PV269 PROJECT - The comparison between the targeted and the whole-genome rDNA assembly

![WDL](https://img.shields.io/badge/Language-WDL-329932?style=flat&logo=bioinformatics&logoColor=white)
![Bash](https://img.shields.io/badge/Script-Bash|Python-4EAA25?style=flat&logo=gnu-bash&logoColor=white)


## Project Overview
The goal of this project is to **compare the contiguity and quality of rDNA assembly** using two approaches:
1.  **Targeted Approach:** Assembly using only reads identified as rDNA.
2.  **Whole-Genome Approach:** Joint assembly of rDNA with all other genomic regions.

To ensure a fair comparison, all variables (e.g. basecalling algorithms, coverage depth, and assembly parameters) are kept consistent across both methods. This study aims to determine the optimal strategy for resolving complex repetitive rDNA regions in the human genome.

## 🛠️ Environment Set-up

### Software Dependencies
The pipeline relies on the following tools.

**Bioinformatics Tools:**
<br>
![Hifiasm](https://img.shields.io/badge/Hifiasm-0.25.0-008080)
![Minimap2](https://img.shields.io/badge/Minimap2-2.30-008080)
![Samtools](https://img.shields.io/badge/Samtools-1.22.1-008080)
![SeqKit](https://img.shields.io/badge/SeqKit-2.12.0-008080)
![Seqtk](https://img.shields.io/badge/Seqtk-1.5-008080)

**Python Packages:**
<br>
![Python](https://img.shields.io/badge/Python-3.10-008080)
![ModDotPlot](https://img.shields.io/badge/ModDotPlot-0.9.8-008080)
![Quast](https://img.shields.io/badge/Quast-5.2.0-008080)
![NanoPlot](https://img.shields.io/badge/NanoPlot-1.46.2-008080)

*(Note: Versions listed are those used during development. Newer versions may work but are not guaranteed.)*

### Environment Installation
1. **Prerequisite:** Ensure [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Mamba](https://mamba.readthedocs.io/en/latest/) is installed.

2. **Create the environment:**
   We provide a pre-configured environment file. Create `environment.yml` with the content below and run:
   ```bash
   conda env create -f environment.yml

### Running WDL Scripts
![Java](https://img.shields.io/badge/Java->11-008080)
[![Cromwell](https://img.shields.io/badge/Cromwell-91-008080)](https://github.com/broadinstitute/cromwell)

This pipeline is written in **WDL** and requires an execution engine to run. The scripts were developed and tested using [**Cromwell**](https://github.com/broadinstitute/cromwell).
```bash
java -jar cromwell-x.jar run script.wdl -i inputs.json
```

### Example Inputs
To run these workflows, you will need to configure input JSON files. Example configurations for each workflow **are provided in the repository** in the `cromwell-example-inputs/` directory.

## Datasets

### 1. Raw Input Data
The analysis uses ONT / Super-accuracy basecalled reads from sample **PAN027** (provided by the Human Pangenome Reference Consortium).

**Source:** [WASHU_PED_DATA / HG06807](https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=submissions/61E64CC7-3281-4387-B428-C284F65B84EE--WASHU_PED_DATA/HG06807/sup_basecalled/)

### 2. Project Data (Terra)
The generated assemblies, reference sequences, and subset test data are stored in a **Google Cloud Storage** bucket on Terra.

**Storage Path:**
```text
gs://fc-b9a7f568-e558-4a23-8d76-c2d67fbe7708/pv269_project.rdna_asssembly_comparison/
```

**Folder Structure:**
* `assemblies` - Final assembly FASTA and GFA files.
* `example-reads` - Subset of reads for testing the pipeline.
* `references` - Reference rDNA sequences.

> **🔒 Access Note:** This bucket is private. Access is restricted exclusively to students of the **PV269 2025** course.

## Pipeline Workflow
The workflow is implemented in **WDL** and consists of the following steps:

1.  **Read QC:**
    * Quality control of basecalled reads using `NanoPlot`.
    * **Script:** `run_nanoplot.wdl`

2.  **rDNA Identification & Extraction:**
    * Alignment of reads to a reference rDNA sequence (e.g., *KY962518.1*) using `Minimap2` and extraction of matching reads.
    * **Script:** `identify_extract_rdna.wdl`

3.  **Assembly:**
    * De novo assembly of the extracted reads using `Hifiasm`.
    * **Script:** `assembly.hifiasm.sh`

4.  **Post-Assembly Processing:**
    * **Filtering:** Removal of small, low-quality contigs or false positives.
        * **Script:** `filter_contigs.wdl`
    * **Extraction:** Isolating specific rDNA contigs from the final assembly.
        * **Script:** `get_rdna_contigs.fasta.wdl`

5.  **Assembly Quality Control:**
    * Assessment of assembly metrics (N50, length, etc.) of assemblies using `QUAST`.
    * **Script:** `run_quast.wdl`

6.  **Visualization:**
    * Generation of self-identity dot plots.
     * **Script:** `run_self-dotplot.wdl`