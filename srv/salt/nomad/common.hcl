bind_addr = "{{internal_ip}}"
data_dir  = "/var/lib/nomad"

advertise {
    # Defaults to the node's hostname. If the hostname resolves to a loopback
    # address you must manually configure advertise addresses.
    http = "{{internal_ip}}"
    rpc  = "{{internal_ip}}"
    serf = "{{internal_ip}}"
}
