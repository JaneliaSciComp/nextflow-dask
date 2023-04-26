def default_dask_params() {
    [
        dask_container: 'registry.int.janelia.org/janeliascicomp/dask:2023.3.2',
        with_dask_dashboard: true,
        dask_scheduler_port: 0,
        dask_dashboard_port: 0,
        dask_scheduler_cores: 1,
        dask_scheduler_mem_gb_per_core: 1,
        dask_workers: 1,
        dask_worker_base_port: 0,
        dask_worker_cores: 1,
        dask_worker_threads: 1,
        dask_worker_mem_gb_per_core: 1,
        required_dask_workers: 0,
        file_check_interval_in_seconds: 5,
        dask_cluster_start_timeout: 120,
        terminate_dask_cluster_marker: 'terminate'
    ]
}
