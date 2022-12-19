process DASK_CLUSTER_TERMINATE {
    container { params.dask_container }
    label 'process_low'

    input:
    val(work_dir)

    output:
    val(work_dir)

    script:
    def terminate_file_name = "${work_dir}/${params.terminate_cluster_marker}"
    """
    echo "\$(date): Terminate DASK Scheduler: ${work_dir}"
    # ensure the work dir exists
    # this may happen in some testing use cases in which 
    # terminate is invoked immediately after start
    mkdir -p ${work_dir}
    cat > ${terminate_file_name} <<EOF
    DONE
    EOF
    cat ${terminate_file_name}
    """
}