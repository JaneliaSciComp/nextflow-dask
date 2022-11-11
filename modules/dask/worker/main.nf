process DASK_WORKER {
    container = params.dask_container

    input:
    val(work_dir)
    val(worker_id)
    val(terminate_name)

    output:
    val()

    script:
    
    """
    echo "$(date): Start DASK Worker ${worker_id}"
    """

}