#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {
    default_dask_params;
} from './lib/dask_params';

final_params = default_dask_params() + params

include {
    CREATE_DASK_CLUSTER;
} from './workflows/create_dask_cluster' addParams(final_params);

include {
    DASK_CLUSTER_TERMINATE;
} from './modules/dask/cluster_terminate/main' addParams(final_params);

workflow {
    def res = CREATE_DASK_CLUSTER(file(params.work_dir))

    res | view

    res
    | map { it.work_dir }
    | DASK_CLUSTER_TERMINATE

}
