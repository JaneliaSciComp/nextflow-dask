include {
    dask_scheduler_info;
    get_mounted_vols_opts;
    lookup_ip_script;
    wait_for_file_script;
} from '../../../lib/dask_process_utils';

process DASK_WORKER {
    container params.dask_container
    containerOptions { "${params.runtime_opts} ${get_published_ports_options(worker_id)} ${get_mounted_vols_opts(worker_accessible_paths)}" }
    cpus { params.worker_cores }
    memory "${params.worker_cores * params.worker_mem_gb_per_core} GB"
    tag "worker-${worker_id}"
    label 'workerClusterOptions'

    input:
    tuple val(work_dir), val(worker_id)
    val(worker_accessible_paths) // this must be a value channel containing a list of paths 
                                 // that must be made available - it can be an empty list

    output:
    val(work_dir)

    script:
    def scheduler_file ="${work_dir}/${dask_scheduler_info()}"
    def worker_port_arg = params.worker_base_port > 0
                            ? "--worker-port ${params.worker_base_port+worker_id-1}"
                            : ""
    def lookup_ip = lookup_ip_script()
    def worker_name = "worker-${worker_id}"
    def worker_mem = "${params.worker_cores * params.worker_mem_gb_per_core}GB"
    def terminate_file_name = "${work_dir}/${params.terminate_cluster_marker}"
    def worker_work_dir = "${work_dir}/${worker_name}"
    def worker_pid_file = "${worker_work_dir}/${worker_name}.pid"
    def threads_per_worker_arg = params.worker_threads > 0 
                                    ? "--nthreads ${params.worker_threads}"
                                    : ""

    """
    if [[ -e ${terminate_file_name} ]] ; then
        # this can happen if the cluster is created on LSF and the workers cannot get nodes 
        # before the cluster is ended
        echo "Do not start worker ${worker_name} because cluster has been terminated already"
        exit 1
    fi

    ${wait_for_file_script(params.file_check_interval_in_seconds, params.dask_cluster_start_timeout)}

    wait_for_file ${scheduler_file}

    mkdir -p ${worker_work_dir}

    echo "\$(date): Start DASK Worker ${worker_id} -> ${work_dir}"
    scheduler_ip=\$(jq -r ".address" "${scheduler_file}")
    echo "Found scheduler IP: \${scheduler_ip}"

    # Start a worker in background
    ${lookup_ip}

    dask worker \
        --name ${worker_name} \
        --host \${LOCAL_IP} \
        ${worker_port_arg} \
        --memory-limit ${worker_mem} \
        --pid-file "${worker_pid_file}" \
        --local-directory ${worker_work_dir} \
        ${threads_per_worker_arg} \
        \${scheduler_ip} 2> >(tee ${worker_work_dir}/${worker_name}.log >&2) \
        &
    # wait for PID file (the default wait has a timeout so no need for one here)
    wait_for_file ${worker_pid_file}

    trap "kill -9 \$(cat ${worker_pid_file}) &> /dev/null" EXIT

    # And wait for the termination marker (forever)
    wait_for_file ${terminate_file_name} -1
    """
}

def get_published_ports_options(worker_id) {
    if (workflow.containerEngine == 'docker') {
        return params.worker_base_port > 0
                ? "-p ${params.worker_base_port+worker_id-1}:${params.worker_base_port+worker_id-1}"
                : ''
    }
    return ''
}