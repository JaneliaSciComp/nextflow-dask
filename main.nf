#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {
    default_dask_params;
} from './lib/dask_params';

final_params = default_dask_params() + params

include {
    CREATE_DASK_CLUSTER;
} from './subworkflows/create_dask_cluster/main' addParams(final_params);

workflow {
    def work_dir=Channel.of('test')
    CREATE_DASK_CLUSTER(work_dir)
}
