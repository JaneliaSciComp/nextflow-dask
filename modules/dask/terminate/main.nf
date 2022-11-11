process DASK_TERMINATE {
    container = params.dask_container

    input:
    val(work_dir)

    output:
    val(work_dir)

    script:
    """
    echo "$(date): Terminate DASK Scheduler"
    echo "!!!!! TODO"
    """
}