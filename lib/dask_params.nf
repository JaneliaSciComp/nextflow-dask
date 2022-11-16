def default_dask_params() {
    [
        container: 'registry.int.janelia.org/janeliascicomp/dask:1.0',
        work_dir: '',
        with_dashboard: true,
        port: 0,
        dashboard_port: 0,
        scheduler_cores: 1,
        scheduler_mem_gb_per_core: 1,
        workers: 1,
        worker_cores: 1,
        worker_threads: 2,
        worker_mem_gb_per_core: 1,
        worker_cluster_opts: '', // specific worker cluster options in case a GPU is needed
        file_check_interval_in_seconds: 2,
        scheduler_start_timeout: 30,
        terminate_cluster_marker: 'terminate-dask'
    ]
}
