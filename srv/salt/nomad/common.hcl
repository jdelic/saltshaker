bind_addr = "{{internal_ip}}"
data_dir  = "/var/lib/nomad"

disable_update_check = {{disable_update_check}}

advertise {
    # Defaults to the node's hostname. If the hostname resolves to a loopback
    # address you must manually configure advertise addresses.
    http = "{{internal_ip}}"
    rpc  = "{{internal_ip}}"
    serf = "{{internal_ip}}"
}

plugin "docker" {
    config {
        endpoint = "unix:///var/run/docker.sock"

        extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]

        gc {
            image       = true
            image_delay = "3m"
            container   = true

            dangling_containers {
                enabled        = true
                dry_run        = false
                period         = "5m"
                creation_grace = "5m"
            }
        }

        volumes {
            enabled      = true
            selinuxlabel = "z"
        }

        # allow_privileged is required to run Hetzner CSI drivers, which require privileges to attach volumes.
        allow_privileged = true
        allow_caps       = ["chown", "net_raw"]
    }
}
