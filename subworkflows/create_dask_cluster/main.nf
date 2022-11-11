include {
    DASK_SCHEDULER;
} from '../../modules/dask/scheduler/main'

workflow CREATE_DASK_CLUSTER {
    take:
    work_dir

    main:

    def scheduler_res = DASK_SCHEDULER(work_dir);

    emit:
    done = scheduler_res

}