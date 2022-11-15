include {
    dask_scheduler_info;
    wait_for_file_script;
} from '../../../lib/dask_process_utils';

process DASK_WORKER {
    container params.container
    cpus { params.worker_cores }
    memory "${params.worker_cores * params.worker_mem_gb_per_core} GB"

    input:
    tuple val(work_dir), val(worker_id)

    output:
    val(work_dir)

    script:
    def scheduler_file ="${work_dir}/${dask_scheduler_info()}"
    def worker_name = "worker-${worker_id}"
    def worker_mem = "${params.worker_cores * params.worker_mem_gb_per_core}GB"
    def terminate_file_name = "${work_dir}/${params.terminate_cluster_marker}"
    def worker_work_dir = "${work_dir}/${worker_name}"
    """
    ${wait_for_file_script(params.file_check_interval_in_seconds, params.scheduler_start_timeout)}

    wait_for_file ${scheduler_file}

    mkdir -p ${worker_work_dir}

    echo "\$(date): Start DASK Worker ${worker_id} -> ${work_dir}"
    scheduler_ip=\$(jq -r ".address" "${scheduler_file}")
    echo "Found scheduler IP: \${scheduler_ip}"
    # Start a worker in background
    dask worker \
        --name ${worker_name} \
        --memory-limit ${worker_mem} \
        --pid-file "${worker_work_dir}/${worker_name}.pid" \
        --local-directory ${worker_work_dir} \
        \${scheduler_ip} &
    # And wait for the termination marker
    wait_for_file "${terminate_file_name}" -1
    """
}
