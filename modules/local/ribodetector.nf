process RIBODETECTOR {
    tag "${meta.id}"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::ribodetector=0.2.7" : null)
    // TODO: Replace the container below with the followng once the container is available
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/ribodetector=0.2.7':
    //     'quay.io/biocontainers/ribodetector=0.2.7' }"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://philpalmer/ribodetector:0.2.7':
        'philpalmer/ribodetector:0.2.7' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${prefix}.nonrrna*fq.gz") , emit: nonrrna_reads
    path "versions.yml"                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output_reads = meta.single_end ? "${prefix}.nonrrna.fq.gz" : "${prefix}.nonrrna.1.fq.gz ${prefix}.nonrrna.2.fq.gz"
    """
    ribodetector_cpu -t ${task.cpus} \
        -l 150 \
        -i $reads \
        -e rrna \
        -o $output_reads
    gzip ${prefix}.nonrrna*.fq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ribodetector: \$(echo \$(ribodetector --version 2>&1) | sed 's/^.*genomad, version //')
    END_VERSIONS
    """
}