include {
    lookup_ip_script;
    wait_for_file_script;
} from '../../../lib/dask_process_utils';

process DASK_SCHEDULER {
    container { params.container }
    cpus { params.scheduler_cores }
    memory "${params.scheduler_cores * params.scheduler_mem_gb_per_core} GB"

    input:
    val(work_dirname) // work_dirname must be unique for the cluster

    output:
    tuple val(work_dirname), val(scheduler_file)

    script:
    def with_dashboard = params.with_dashboard 
                            ? "--dashboard"
                            : ""
    def dask_port = params.port > 0
                        ? "--port ${params.port}"
                        : ""
    def dashboard_port = params.dashboard_port > 0 
                            ? "--dashboard-address ${params.dashboard_port}"
                            : ""
    def lookup_ip = lookup_ip_script()
    def work_dir = file(work_dirname)
    def scheduler_pid_file ="${work_dir}/scheduler.pid"
    scheduler_file ="${work_dir}/scheduler.conn"
    def terminate_file_name = "${work_dir}/${params.terminate_cluster_marker}"
    """
    # do not timeout
    ${wait_for_file_script(params.file_check_interval_in_seconds, -1)}

    echo "\$(date): Start DASK Scheduler in ${work_dir}"
    ${lookup_ip}

    dask scheduler \
        ${with_dashboard} \
        ${dashboard_port} \
        --host \${LOCAL_IP} \
        ${dask_port} \
        --pid-file ${scheduler_pid_file} \
        --scheduler-file ${scheduler_file} &

    wait_for_file "${terminate_file_name}"
    """
}
