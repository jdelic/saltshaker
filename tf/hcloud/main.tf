terraform {
    required_providers {
        hcloud = {
            source  = "hetznercloud/hcloud"
            version = "> 1.0"
        }
    }
}

variable "hcloud_token" {
    sensitive = true
}

provider "hcloud" {
    token = var.hcloud_token
}

locals {
    saltmaster_config = templatefile("${path.module}/../../etc/salt-master/master.d/saltshaker.conf", {})

    server_config = {
        "db.maurusnet.internal" = {
            server_type = "cx22"
            backup = 1
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
            user_data = templatefile("${path.module}/../salt-minion.cloud-init.yml", {
                saltmaster_ip = flatten(hcloud_server.saltmaster.network.*.ip)[0]
                roles = ["database", "vault", "authserver"]
                ipv6_only = true,
                hostname = "db.maurusnet.internal"
            })
        }
/*      dev = {
            server_type = "cx32"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        "mail.maurus.net" = {
            server_type = "cpx21"
            backup = 1
            additional_ipv4 = 1
            ipv6_only = 0
            internal_only = 0
            ptr = "mail.maurus.net"
        }
        "apps1.maurusnet.internal" = {
            server_type = "cx22"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        "apps2.maurusnet.internal" = {
            server_type = "cx22"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        "apps3.maurusnet.internal" = {
            server_type = "cx22"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        backup.maurusnet.internal = {
            server_type = "bx11"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        } */
    }
}

/*
 NETWORK CONFIGURATION
 The following stanzas create first:
   - a network 10.0.0.0/20, which comes with a gateway at 10.0.0.1 where
     ALL traffic must be routed from each node. Routing will then be applied
     on that gateway.
   - a subnet 10.0.1.0/24 in the network, which is the subnet where all
     servers will be placed.
   - a route on the network to route all traffic for the internet (0.0.0.0)
     to the designated NAT gateway for the 10.0.1.0/24 subnet.
   - the designated NAT gateway is the saltmaster at 10.0.1.1. It has the
     natgateway Salt role which configures its network and nftables
     accordingly.
   - Servers without a public IP will be able to reach the internet through
     the NAT gateway. For that they need to send their traffic to the
     network gateway which will route it to saltmaster.

         ip route add default via 10.0.0.1 dev ens10
*/
resource "hcloud_network" "internal" {
    name = "private-network"
    ip_range = "10.0.0.0/20"
}

resource "hcloud_network_subnet" "internal-subnet" {
    type = "cloud"
    network_id = hcloud_network.internal.id
    network_zone = "eu-central"
    ip_range = "10.0.1.0/24"
}

resource "hcloud_network_route" "nat-route" {
    network_id = hcloud_network.internal.id
    destination = "0.0.0.0/0"
    gateway = flatten(hcloud_server.saltmaster.network.*.ip)[0]
    depends_on = [hcloud_server.saltmaster]
}

resource "hcloud_server" "saltmaster" {
    name = "symbiont.maurus.net"
    server_type = "cx22"
    image = "debian-12"
    location = "hel1"
    ssh_keys = ["symbiont laptop key", "jonas@hades"]

    network {
        network_id = hcloud_network.internal.id
    }

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }

    user_data = templatefile("${path.module}/../salt-master.cloud-init.yml", {
        saltmaster_config = file("${path.module}/../../etc/salt-master/master.d/saltshaker.conf")
        hostname = "symbiont.maurus.net"
    })

    backups = true
    # important as per hcloud docs as there's a race condition otherwise
    depends_on = [hcloud_network_subnet.internal-subnet]
}

resource "hcloud_server" "servers" {
    for_each = local.server_config

    name = each.key
    server_type = each.value.server_type
    image = "debian-12"
    location = "hel1"
    ssh_keys = ["symbiont laptop key", "jonas@hades"]

    network {
        network_id = hcloud_network.internal.id
    }

    public_net {
        ipv4_enabled = each.value.ipv6_only == 1 ? false : true
        ipv6_enabled = each.value.internal_only == 1 ? false : true
    }

    user_data = lookup(each.value, "user_data", null)

    backups = each.value.backup == 1 ? true : false

    # important as per hcloud docs as there's a race condition otherwise
    depends_on = [hcloud_network_subnet.internal-subnet, hcloud_server.saltmaster]
}

resource "hcloud_floating_ip" "additional_ipv4" {
    for_each = { for k, v in local.server_config : k => v if v.additional_ipv4 == 1 }
    type = "ipv4"
    server_id = hcloud_server.servers[each.key].id
}

/*resource "hcloud_load_balancer" "app_lb" {
    name = "app-load-balancer"
    location = "hel1"
    load_balancer_type = "lb11"
}

resource "hcloud_load_balancer_target" "app_targets" {
    for_each = { for k, v in local.server_config : k => v if k == "apps1" || k == "apps2" || k == "apps3" }
    load_balancer_id = hcloud_load_balancer.app_lb.id
    type = "server"
    server_id = hcloud_server.servers[each.key].id
}*/

output "ip_addresses" {
    value = {
        for s in merge({"symbiont.maurus.net" = hcloud_server.saltmaster}, hcloud_server.servers) : s.name => concat(
            s.ipv4_address != "" ? [s.ipv4_address] : [],
            s.ipv6_address != "" ? [s.ipv6_address] : [],
            flatten(s.network.*.ip),
            [for ip in hcloud_floating_ip.additional_ipv4 : ip.ip_address if ip.server_id == s.id]
        )
    }
}
