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

process plink_map {
    input:
    path invcf
    output:
    path "plink.map"

    script:
    """
    zcat $invcf | head -n 1000 \
        | grep "^##contig=" \
        | grep Chr \
        | awk -F'[=,]+' '{ print \$3 }' \
        | plink_map.sh > plink.map
    """
}

process download_beagle {
    output:
    path "*.jar"
    
    script:
    """
    wget https://faculty.washington.edu/browning/beagle/beagle.29Oct24.c8e.jar
    """
}

process download_ibdhap {
    output:
    path "*.jar"
    
    script:
    """
    wget https://faculty.washington.edu/browning/hap-ibd.jar
    """
}

process beagle {
    // Assign name of the species
    publishDir 'results/phased', mode: 'copy'
    maxForks 1
    input:
    tuple path(sample_file), path(vcf), path(index), path(binary), path(map)

    output:
    path "*vcf.gz"

    script:
    """
    # Extract samples
    bcftools view -O z -S $sample_file $vcf > out.vcf.gz
    base=\$(basename $sample_file .txt)
    java -jar $binary gt=out.vcf.gz map=$map nthreads=8 seed=1000 out=\$base
    rm out.vcf.gz
    """
}

process ibd {
    publishDir 'results/ibd', mode: 'copy'
    input:
    tuple path(phased), path(binary), path(map)
    output:
    path "*.ibd.gz"
    path "*.hbd.gz"

    script:
    """
    base=\$(basename $phased .vcf.gz)
    java -jar $binary gt=$phased map=$map nthreads=8 out=\$base
    """

}

workflow {
    metadata = file(params.metadata)
    species = Channel.fromList(["Telmatherina sarasinorum", "Telmatherina opudi"]).flatten()
    invcf = Channel.fromPath(params.vcf)
    index = Channel.fromPath(params.vcf + ".tbi")
    beagle_binary = download_beagle()
    map_file = plink_map(invcf)
    input = samples(metadata, species)
        .combine(invcf)
        .combine(index)
        .combine(beagle_binary)
        .combine(map_file)
    phased = beagle(input)
    ibdhap_binary = download_ibdhap()
    phased
        .combine(ibdhap_binary)
        .combine(map_file)
        .set { ibd_input }
    ibd(ibd_input)
}