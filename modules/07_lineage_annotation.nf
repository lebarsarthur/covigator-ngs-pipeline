params.memory = "3g"
params.cpus = 1
params.output = "."


process PANGOLIN_LINEAGE {
    cpus params.cpus
    memory params.memory
    publishDir "${params.output}", mode: "copy"
    tag "${name}"

    conda (params.enable_conda ? "bioconda::pangolin=3.1.19" : null)

    input:
        tuple val(name), val(caller), file(fasta)

    output:
        file("${name}.${caller}.pangolin.csv")

    shell:
    """
    pangolin --outfile ${name}.${caller}.pangolin.csv ${fasta}
    """
}

process VCF2FASTA {
    cpus params.cpus
    memory params.memory
    tag "${name}"

    conda (params.enable_conda ? "conda-forge::gsl=2.7 bioconda::bcftools=1.14" : null)

    input:
        tuple val(name), val(caller), file(vcf)
        val(reference)

    output:
        tuple val(name), val(caller), file("${name}.${caller}.fasta")

    shell:
    """
    bcftools index ${vcf}

    # GATK results have all FILTER="."
    bcftools consensus --fasta-ref ${reference} \
    --include 'FILTER="PASS" | FILTER="."' \
    --output ${name}.${caller}.fasta \
    ${vcf}
    """
}
