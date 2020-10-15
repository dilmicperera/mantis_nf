#!/usr/bin/env nextflow
import java.nio.file.Paths

//params.output_folder = '/data/dperera/outputs/test_docker'
//params.bam_folder = '/data/dperera/from_s3/200817_M02558_0388_000000000-J6PKJ'

bam_folder="$projectDir/$params.bam_folder"
loci_file_mantis = "$projectDir/$params.loci_file_mantis"

normal_bam = "$projectDir/$params.normal_bam"
normal_bai = "$projectDir/$params.normal_bai"

genome_fa = file(params.genome_fa)
genome_fa_fai = file(params.genome_fa_fai)

//genome_fa = "/home/dperera/hg19.fa"
//genome_fa_fai = "/home/dperera/hg19.fa.fai"


// Read in bam files
bam_paths = Paths.get(bam_folder,"/DNA*/DNA*[0-9].hardclipped.bam")
bam_files = Channel.fromPath(bam_paths)

// Read in bai files
bai_paths = Paths.get(bam_folder,"/DNA*/DNA*[0-9].hardclipped.bam.bai")
bai_files = Channel.fromPath(bai_paths)



/**************
** MANTIS **
***************/

process run_mantis{
    publishDir params.output_folder

    input:
        file tumour_bam from bam_files
	file tumour_bai from bai_files
        path normal_bam
        path normal_bai
        file genome_fa
        file genome_fa_fai
        path loci_file_mantis
    output:
        file "${tumour_bam.baseName}.mantis.status" into mantis_outputs

    """
    python3 /opt/mantis/mantis.py --bedfile $loci_file_mantis --genome $genome_fa -n $normal_bam -t ${tumour_bam} -o ${tumour_bam.baseName}.mantis
    """
}

