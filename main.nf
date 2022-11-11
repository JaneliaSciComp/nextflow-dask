#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {
    CREATE_DASK_CLUSTER;
} from './subworkflows/create_dask_cluster/main'

workflow {
    def work_dir=Channel.of('test')
    CREATE_DASK_CLUSTER(work_dir)
}
