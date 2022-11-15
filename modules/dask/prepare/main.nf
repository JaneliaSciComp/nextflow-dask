process DASK_PREPARE {
    container { params.container }
    label 'process_low'

    input:
    val(work_dirname)

    output:
    val(cluster_work_dir)

    script:
    def work_dir = file(work_dirname)
    cluster_work_dir = "${work_dir}/${workflow.sessionId}"
    log.info "Cluster working dir: ${cluster_work_dir}"
    """
    echo "Create cluster working dir: ${cluster_work_dir}"
    mkdir -p ${cluster_work_dir}
    """
}
