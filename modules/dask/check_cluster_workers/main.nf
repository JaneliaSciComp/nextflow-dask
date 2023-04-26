include {
    dask_scheduler_info;
    wait_for_file_script;
} from '../../../lib/dask_process_utils';

process DASK_CHECK_CLUSTER_WORKERS {
    container params.dask_container
    label 'process_low'

    input:
    tuple val(cluster_id), val(scheduler_address), val(work_dir)

    output:
    tuple val(cluster_id), val(scheduler_address), val(work_dir), env(connected_workers)

    script:
    def terminate_file_name = "${work_dir}/${params.terminate_dask_cluster_marker}"
    def n_required_workers = params.required_dask_workers > 0
                                ? params.required_dask_workers
                                : params.dask_workers
    """
    required_workers=${n_required_workers}
    if (( \${required_workers} > 0 )); then
        total_workers=\$((${params.dask_workers}))
        seconds=0
        wait_timeout=\$((${params.dask_cluster_start_timeout}))
        polling_interval=\$((${params.file_check_interval_in_seconds}))
        while true; do
            if [[ -e ${terminate_file_name} ]] ; then
                # this can happen if the cluster is created on LSF and the workers cannot get nodes
                # before the cluster is ended
                connected_workers=-1
                exit 1
            fi
            connected_workers=0
            for (( worker_id=1; worker_id<=\${total_workers}; worker_id++ )); do
                worker_name="worker-\${worker_id}"
                worker_log="${work_dir}/\${worker_name}/\${worker_name}.log"
                # if worker's log exists check if the worker has connected to the scheduler
                echo "Check \${worker_log}"
                if [[ -e "\${worker_log}" ]]; then
                    found=`grep -o "Registered to:.*${scheduler_address}" \${worker_log} || true`
                    if [[ ! -z \${found} ]]; then
                        echo "\${found}"
                        connected_workers=\$(( \$connected_workers + 1 ))
                    fi
                fi
            done
            echo "Found \${connected_workers} after \${seconds}"
            # in case somebody forgets to adjust the required workers check also if it is equal to total_workers
            if (( \${connected_workers} >= \${total_workers} || \${connected_workers} >= \${required_workers} )); then
                echo "Found \${connected_workers} connected workers"
                break;
            fi
            if (( \${wait_timeout} > 0 && \${seconds} > \${wait_timeout} )); then
                echo "Timed out after \${seconds} seconds while waiting for at least \${required_workers} workers to connect to scheduler"
                connected_workers=-1
                exit 2
            fi
            sleep \$polling_interval
            seconds=\$(( \$seconds + \$polling_interval ))
        done
    else
        connected_workers=-1
    fi
    """
}
