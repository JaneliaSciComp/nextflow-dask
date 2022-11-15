include {
    DASK_PREPARE;
} from '../../modules/dask/prepare/main'

include {
    DASK_SCHEDULER;
} from '../../modules/dask/scheduler/main'

include {
    DASK_WORKER;
} from '../../modules/dask/worker/main'

workflow CREATE_DASK_CLUSTER {
    take:
    work_dir

    main:

    def cluster_work_dir = DASK_PREPARE(work_dir)
    // start dask scheduler
    def scheduler_res = DASK_SCHEDULER(cluster_work_dir);
    // start dask workers
    def worker_res = DASK_WORKER(cluster_work_dir.combine(create_worker_list()));

    emit:
    done = scheduler_res
}

def create_worker_list() {
    def nworkers = params.workers
    return 1..nworkers
}