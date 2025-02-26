process KRONA {
    tag "${meta.classifier}-${meta.id}"

    conda (params.enable_conda ? "bioconda::krona=2.7.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/krona:2.7.1--pl526_5' :
        'quay.io/biocontainers/krona:2.7.1--pl526_5' }"

    input:
    tuple val(meta), path(report)
    path  "taxonomy/taxonomy.tab"

    output:
    path "*.html"       , emit: html
    path "versions.yml" , emit: versions

    script:
    """
    ktImportTaxonomy "$report" -tax taxonomy

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ktImportTaxonomy: \$(ktImportTaxonomy 2>&1 | sed -n '/KronaTools /p' | sed 's/^.*KronaTools //; s/ - ktImportTaxonomy.*//')
    END_VERSIONS
    """
}
