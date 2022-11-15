include {
    dask_scheduler_info;
    wait_for_file_script;
} from '../../../lib/dask_process_utils';

process DASK_CLUSTER_INFO {
    container { params.container }
    label 'process_low'

    input:
    val(work_dir)

    output:
    tuple val(work_dir), env(scheduler_info)

    script:
    def scheduler_file ="${work_dir}/${dask_scheduler_info()}"
    """
    ${wait_for_file_script(params.file_check_interval_in_seconds, params.scheduler_start_timeout)}

    wait_for_file ${scheduler_file}
    echo "\$(date): Get cluster info from ${scheduler_file}"
    scheduler_info=\$(cat "${scheduler_file}")
    """
}
