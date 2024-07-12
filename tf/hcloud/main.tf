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

    saltmaster_init = templatefile("${path.module}/../salt-master.cloud-init.yml", {
        saltmaster_config = local.saltmaster_config
    })

    server_config = {
        db = {
            server_type = "cx21"
            backup = 1
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
            user_data = templatefile("${path.module}/../salt-minion.cloud-init.yml", {
                saltmaster_ip = "10.0.1.1",
                ipv6_only = true,
                roles = ["database"],
                hostname = "db.maurusnet.internal"
            })
            depends_on = ["saltmaster"]
        }
        /*
        dev = {
            server_type = "cx31"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        mail = {
            server_type = "cpx21"
            backup = 1
            additional_ipv4 = 1
            ipv6_only = 0
            internal_only = 0
            ptr = "mail.maurus.net"
        }
        apps1 = {
            server_type = "cx21"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        apps2 = {
            server_type = "cx21"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        apps3 = {
            server_type = "cx21"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        }
        backup = {
            server_type = "bx11"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
            internal_only = 1
            ptr = null
        } */
    }
}

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

resource "hcloud_server" "saltmaster" {
    name = "saltmaster"
    server_type = "cx11"
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

    user_data = local.saltmaster_init
    backups = false
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
        for s in merge({ saltmaster = hcloud_server.saltmaster }, hcloud_server.servers) : s.name => concat(
            s.ipv4_address != "" ? [s.ipv4_address] : [],
            s.ipv6_address != "" ? [s.ipv6_address] : [],
            flatten(s.network.*.ip),
            [for ip in hcloud_floating_ip.additional_ipv4 : ip.ip_address if ip.server_id == s.id]
        )
    }
}
