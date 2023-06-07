include {
    DASK_PREPARE;
} from '../modules/local/dask_prepare.nf'

include {
    DASK_SCHEDULER;
} from '../modules/dask/scheduler/main'

include {
    DASK_WORKER;
} from '../modules/dask/worker/main'

include {
    DASK_CLUSTER_INFO;
} from '../modules/dask/cluster_info/main'

include {
    DASK_CHECK_CLUSTER_WORKERS
} from '../modules/dask/check_cluster_workers/main'

include {
    as_string
    json_text_to_data;
} from '../lib/dask_process_utils'

workflow CREATE_DASK_CLUSTER {
    take:
    base_work_dir
    cluster_accessible_paths

    main:
    def cluster_work_dir = DASK_PREPARE(base_work_dir)
    def cluster_path_binds = cluster_accessible_paths.filter(it).ifEmpty('')
    | map { as_string(it) }

    // start dask scheduler
    log.debug "Create a dask cluster with ${params.dask_workers} workers"

    DASK_SCHEDULER(cluster_work_dir, cluster_path_binds)

    def worker_input = cluster_work_dir
    | combine(create_worker_list(params.dask_workers))
    | combine(cluster_path_binds) // cluster paths are needed in ever worker

    worker_input.subscribe { log.debug "Worker input: $it" }
    // start dask workers
    DASK_WORKER(worker_input.map { it[0..1] },
                worker_input.map { it[2] })

    // get cluster info
    def cluster_info = DASK_CLUSTER_INFO(cluster_work_dir, cluster_path_binds)
    | map {
        def (wd, ci) = it
        def ci_json = json_text_to_data(ci)
        [
            ci_json.id, // cluster id
            ci_json.address, // scheduler address
            wd // cluster work dir
        ]
    }
    | DASK_CHECK_CLUSTER_WORKERS

    cluster_info | subscribe { log.debug "Cluster info: $it" }

    emit:
    done = cluster_info
}

def create_worker_list(nworkers) {
    return 1..nworkers
}
