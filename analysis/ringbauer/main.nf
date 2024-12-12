#!/usr/bin/env nextflow

process samples {
    input:
    path metadata
    val species
    output:
    path "*.txt"

    script:
    """
    echo $species
    # Replace whitespace with underscore
    basename=\$(echo $species | sed 's/ /_/g')
    grep '$species' < $metadata | cut -f1 > \$basename.txt
    """
}

process analysis {
    publishDir 'results', mode: 'copy'
    errorStrategy 'ignore'
    maxForks 2
    input:
    tuple path(species), val(chrom), path(vcf), path(index)
    output:
    path "*GONE2_Ne"

    script:
    """
    outfile=\$(basename $species .txt)_$chrom
    echo \$outfile
    bcftools view -r $chrom -S $species $vcf > out.vcf
    gone2 -s 2000000 -r 25 -g 0 -t 4 -o \$outfile out.vcf
    rm out.vcf
    """
}

workflow {
    metadata = file(params.metadata)
    species = Channel.fromList(["Telmatherina sarasinorum", "Telmatherina opudi"]).flatten()
    chromosomes = Channel.from(1..24).map{ "Chr$it" }

    // Get VCF of all samples
    all = Channel.fromPath(params.vcf)
    index = Channel.fromPath(params.vcf + ".tbi")
    // Subset VCF for each species and chromosome
    input = samples(metadata, species)
        .combine(chromosomes)
        .combine(all)
        // This would break if more than one VCF file is provided
        .combine(index)
    analysis(input)
}