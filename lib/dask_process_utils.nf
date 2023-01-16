def dask_scheduler_info() {
    'scheduler-info.json'
}

def lookup_ip_script() {
    if (workflow.containerEngine == "docker") {
        return lookup_ip_inside_docker_script()
    } else {
        return lookup_local_ip_script()
    }
}

def lookup_local_ip_script() {
    // Take the last IP that's listed by hostname -i.
    // This hack works on Janelia Cluster and AWS EC2.
    """
    LOCAL_IP=`hostname -i | rev | cut -d' ' -f1 | rev`
    echo "Use IP: \$LOCAL_IP"
    if [[ -z "\${LOCAL_IP}" ]] ; then
        echo "Could not determine local IP: LOCAL_IP is empty"
        exit 1
    fi
    """
}

def lookup_ip_inside_docker_script() {
    """
    LOCAL_IP=
    for interface in /sys/class/net/{eth*,en*,em*}; do
        [ -e \$interface ] && \
        [ `cat \$interface/operstate` == "up" ] && \
        LOCAL_IP=\$(ifconfig `basename \$interface` | grep "inet " | awk '\$1=="inet" {print \$2; exit}' | sed s/addr://g)
        if [[ "\$LOCAL_IP" != "" ]]; then
            echo "Use IP: \$LOCAL_IP"
            break
        fi
    done
    if [[ -z "\${LOCAL_IP}" ]] ; then
        echo "Could not determine local IP: LOCAL_IP is empty"
        exit 1
    fi
    """
}

def wait_for_file_script(interval, timeout) {
    """
    function wait_for_file() {
        local f=\$1
        local -i wait_timeout=\${2:-${timeout}}
        local -i seconds=0
        local -i polling_interval=${interval}

        if (( \${wait_timeout} > 0  )); then
            echo "Check for \${f} with a timeout of \${wait_timeout} seconds"
        else
            echo "Check for \${f} with NO timeout"
        fi

        while ! [[ -e \${f} ]] ; do
            if (( \${wait_timeout} > 0 && \${seconds} > \${wait_timeout} )); then
                echo "Timed out after \${seconds} seconds while waiting for \${f}"
                exit 2
            fi
            sleep \$polling_interval
            seconds=\$(( \$seconds + \$polling_interval ))
        done
        echo "Found \${f}"
    }
    """
}

def json_text_to_data(text) {
    def jsonSlurper = new groovy.json.JsonSlurper()
    jsonSlurper.parseText(text)
}

def normalized_file_name(f) {
    if (f) {
        "${file(f)}"
    } else {
        ''
    }
}

def get_mounted_vols_opts(paths) {
    def unique_paths = as_list(paths)
                        .collect { normalized_file_name(it) }
                        .findAll { it ? true : false }
                        .unique(false)
    switch (workflow.containerEngine) {
        case 'docker': 
            return unique_paths
                .collect { "-v $it:$it" }
                .join(' ')
        case 'singularity':
            return unique_paths
                .collect { "-B $it" }
                .join(' ')
        default:
            log.error "Unsupported container engine: ${workflow.containerEngine}"
            ''
    }
}

def as_string(slist) {
    if (!slist) {
        ''
    } else if (slist instanceof List) {
        slist.join(',')
    } else {
        slist as String
    }
}

def as_list(vals) {
    if (!vals) {
        []
    } else if (slist instanceof List) {
        vals
    } else {
        vals.split(',')
    }
}
