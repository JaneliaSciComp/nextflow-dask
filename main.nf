#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {
    default_dask_params;
} from './lib/dask_params';

final_params = default_dask_params() +
               with_termination_params() +
               cluster_paths_params() +
               params

include {
    CREATE_DASK_CLUSTER;
} from './workflows/create_dask_cluster' addParams(final_params);

include {
    DASK_CLUSTER_TERMINATE;
} from './modules/dask/cluster_terminate/main' addParams(final_params);

workflow {
    def res = CREATE_DASK_CLUSTER(file(params.dask_work_dir),
                                  Channel.of(final_params.cluster_paths))

    if (final_params.with_termination) {
        res
        | map {
            def (cluster_id, scheduler_ip, wd) = it
            wd
        }
        | DASK_CLUSTER_TERMINATE
    }
}

def with_termination_params() {
    [
        with_termination: false,
    ]
}

def cluster_paths_params() {
    [
        cluster_paths: '',
    ]
}
