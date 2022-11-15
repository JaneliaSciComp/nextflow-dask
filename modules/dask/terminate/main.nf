process DASK_TERMINATE {
    container = params.container

    input:
    val(work_dir)

    output:
    val(work_dir)

    script:
    def terminate_file_name = "${work_dir}/${params.terminate_cluster_marker}"
    """
    echo "$(date): Terminate DASK Scheduler"
    cat > ${terminate_file_name} <<EOF
    DONE
    EOF
    cat ${terminate_file_name}
    """
}