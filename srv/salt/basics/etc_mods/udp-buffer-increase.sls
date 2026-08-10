# set up a sysctl config to increase the default and max UDP receive buffer sizes,
# which is necessary for livekit to work well under load and help with UDP throughput.
# Should be assigned to nodes handling UDP traffic.

net.core.rmem_max:
    sysctl.present:
        - value: 16777216

net.core.rmem_default:
    sysctl.present:
        - value: 16777216