process DASK_SCHEDULER {
    container = params.dask_container

    input:
    val(work_dir)

    output:
    val(work_dir)

    script:
    def with_dashboard = params.with_dashboard 
                            ? "--dashboard"
                            : ""
    def dask_port = params.dask_port > 0
                        ? "--port ${params.dask_port}"
                        : ""
    def dashboard_port = params.dashboard_port > 0 
                            ? "--dashboard-address ${params.dashboard_port}"
                            : ""
    """
    . /opt/conda/etc/profile.d/conda.sh
    conda activate
    echo "\$(date): Start DASK Scheduler in background"
    dask scheduler ${with_dashboard} ${dashboard_port}
    """
}
