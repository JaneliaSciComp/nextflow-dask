include {
    wait_for_file_script;
} from '../../../lib/dask_process_utils';

process DASK_WORKER {
    container params.container
    cpus { params.worker_cores }
    memory "${params.worker_cores * params.worker_mem_gb_per_core} GB"

    input:
    tuple val(work_dirname), val(worker_id)

    output:
    val(work_dirname)

    script:
    def work_dir = file(work_dirname)
    def scheduler_file ="${work_dir}/scheduler.conn"
    """
    ${wait_for_file_script(params.file_check_interval_in_seconds, params.scheduler_start_timeout)}

    wait_for_file ${scheduler_file}
    echo "\$(date): Start DASK Worker ${worker_id} -> ${work_dirname}"
    scheduler_ip=\$(jq -r ".address" "${scheduler_file}")
    echo "Found scheduler IP: \${scheduler_ip}"
    dask worker \${scheduler_ip}
    """

}