# TODO:
# This state is supposed to setup consul-template so that it renders a haproxy
# configuration that queries all services tagged as external in the local network
# and then creates a loadbalancer across all of them.

# Ideally it uses some form of consul tag to automatically match the HTTP Host
# header, too. What remains then is the question of SNI and SSL certificates,
# i.e. SSL termination.

# Also unsolved: Port autodiscovery for internal routing. A consul servicedef
# should probably tag a service with its SmartStack default port.

# Finally the resulting haproxy instance would run on ports 80 and 443.

include:
    - haproxy.install

# vim: syntax=yaml
