def default_dask_params() {
    [
        container: 'registry.int.janelia.org/janeliascicomp/dask:2022.11.1',
        work_dir: '',
        with_dashboard: true,
        port: 0,
        dashboard_port: 0,
        scheduler_cores: 1,
        scheduler_mem_gb_per_core: 1,
        workers: 1,
        worker_cores: 1,
        worker_threads: 1,
        worker_mem_gb_per_core: 1,
        required_workers: 0,
        file_check_interval_in_seconds: 5,
        dask_cluster_start_timeout: 120,
        terminate_cluster_marker: 'terminate'
    ]
}
