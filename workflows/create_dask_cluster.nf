include {
    DASK_PREPARE;
} from '../modules/dask/prepare/main'

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
    json_text_to_data;
} from '../lib/dask_process_utils'

workflow CREATE_DASK_CLUSTER {
    take:
    base_work_dir

    main:
    def cluster_work_dir = DASK_PREPARE(base_work_dir)

    // start dask scheduler
    DASK_SCHEDULER(cluster_work_dir)

    // start dask workers
    DASK_WORKER(cluster_work_dir.combine(create_worker_list()))

    // get cluster info
    def cluster_info = DASK_CLUSTER_INFO(cluster_work_dir)
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

    emit:
    done = cluster_info
}

def create_worker_list() {
    def nworkers = params.workers
    return 1..nworkers
}
