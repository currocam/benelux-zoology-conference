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
    cat $metadata | grep '$species' | cut -f1 > \$basename.txt
    """
}

process vcf2smc {
    maxForks 8

    input:
    tuple path(sampleFile), path(vcf), path(index_vcf), val(chromosome)

    output:
    path "*_Chr${chromosome}.smc.gz"

    script:
    """
    # Extract the population name from the sample file
    pop=\$(basename ${sampleFile} .txt)
    echo "Processing population: \${pop}"
    # Extract sample names
    samples=\$(cut -f 1 ${sampleFile} | tr '\n' ',' | sed 's/,\$//')
    echo "Samples: \${samples}"
    # Output file
    OUTFILE=\${pop}_Chr${chromosome}.smc.gz
    smcpp_v1.15.4 vcf2smc ${vcf} \$OUTFILE Chr${chromosome} \${pop}:\${samples}
    """
}

process cv {
    input:
    path infiles

    output:
    path "*.final.json"

    script:
    """
    # Get the population name from the input file of the first file
    # (assuming all files are from the same population)
    # <population>_Chr<chromosome>.smc.gz
    pop=\$(basename \$(echo ${infiles[0]} | sed 's/_Chr.*//') )
    smcpp_v1.15.4 cv \
        --folds 5 \
        -c 50000 \
        --cores 8 \
        ${params.mutation_rate} *.smc.gz
    mv *.final.json \${pop}.final.json
    """
}

process estimate {
    input:
    path infiles

    output:
    path "*.final.json"

    script:
    """
    # Get the population name from the input file of the first file
    # (assuming all files are from the same population)
    # <population>_Chr<chromosome>.smc.gz
    pop=\$(basename \$(echo ${infiles[0]} | sed 's/_Chr.*//') )
    smcpp_v1.15.4 estimate \
        -c 50000 \
        --cores 8 \
        ${params.mutation_rate} *.smc.gz
    mv *.final.json \${pop}.final.json
    """
}

workflow {
    // From params
    vcf_file = file(params.vcf)
    // Everything that matches the index_vcf pattern
    index_vcf = file("${params.vcf}.tbi")
    metadata = file(params.metadata)
    // Run CV only for opudo
    species = Channel.fromList(["Telmatherina opudi", "Telmatherina sarasinorum"]).flatten()
    chromosomes = Channel.from(1..24)
    // Create tasks for each chromosome
    samples(metadata, species)
        .combine(chromosomes)
        .map { sampleFile, chromosome -> tuple(sampleFile, vcf_file, index_vcf, chromosome) }
        .set { smc_tasks }
    smc_files = vcf2smc(smc_tasks)
    // Combine all the smc files by population
    input = smc_files
    // They are named as <population>_Chr<chromosome>.smc.gz but 
    |   map {it -> [it.baseName.split("_Chr")[0], it]}
    |   groupTuple
    |   map {_key, files -> files}
    estimate(input).view()
}