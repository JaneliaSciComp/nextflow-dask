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
    // It won't be necessary at all once we add a local option for Spark apps.
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
            echo "Use Spark IP: \$LOCAL_IP"
            break
        fi
    done
    if [[ -z "\${LOCAL_IP}" ]] ; then
        echo "Could not determine local IP: LOCAL_IP is empty"
        exit 1
    fi
    """
}
