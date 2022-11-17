include {
    dask_scheduler_info;
    lookup_ip_script;
    wait_for_file_script;
} from '../../../lib/dask_process_utils';

process DASK_SCHEDULER {
    container { params.container }
    containerOptions { get_container_options() }
    cpus { params.scheduler_cores }
    memory "${params.scheduler_cores * params.scheduler_mem_gb_per_core} GB"

    input:
    val(work_dir) // work_dir must be unique for the cluster

    output:
    val(work_dir)

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
    def scheduler_pid_file ="${work_dir}/scheduler.pid"
    def scheduler_file ="${work_dir}/${dask_scheduler_info()}"
    def terminate_file_name = "${work_dir}/${params.terminate_cluster_marker}"
    """
    if [[ -e ${terminate_file_name} ]] ; then
        echo "Do not start scheduler because cluster has been terminated already"
        exit 1
    fi

    # generate wait script with no timeout as default
    ${wait_for_file_script(params.file_check_interval_in_seconds, -1)}

    echo "\$(date): Start DASK Scheduler in ${work_dir}"
    ${lookup_ip}

    dask-scheduler \
        ${with_dashboard} \
        ${dashboard_port} \
        --host \${LOCAL_IP} \
        ${dask_port} \
        --pid-file ${scheduler_pid_file} \
        --scheduler-file ${scheduler_file} &

    # wait for PID file
    # make sure there is a timeout param since the default wait does not timeout
    wait_for_file ${scheduler_pid_file} ${params.dask_cluster_start_timeout}

    trap "kill -9 \$(cat ${scheduler_pid_file}) &> /dev/null" EXIT

    wait_for_file ${terminate_file_name}
    """
}

def get_container_options() {
    if (workflow.containerEngine == 'docker') {
        if (params.with_dashboard) {
            def dashboard_port = params.dashboard_port > 0
                                    ? params.dashboard_port
                                    : 8787
            return "-p ${dashboard_port}:${dashboard_port}"
        }
    }
    return ''
}