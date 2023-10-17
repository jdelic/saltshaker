terraform {
    required_providers {
        hcloud = {
            source  = "hetznercloud/hcloud"
            version = "> 1.0"
        }
    }
}

variable "hcloud_token" {
    sensitive = true # Requires terraform >= 0.14
}

provider "hcloud" {
    token = var.hcloud_token
}

locals {
    server_config = {
        saltmaster = {
            server_type = "cx11"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
        }
        db = {
            server_type = "cx21"
            backup = 1
            additional_ipv4 = 0
            ipv6_only = 1
        }
        dev = {
            server_type = "cx31"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
        }
        mail = {
            server_type = "cpx21"
            backup = 1
            additional_ipv4 = 1
            ipv6_only = 0
        }
        apps1 = {
            server_type = "cx21"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
        }
        apps2 = {
            server_type = "cx21"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
        }
        apps3 = {
            server_type = "cx21"
            backup = 0
            additional_ipv4 = 0
            ipv6_only = 1
        }
        backup = {
            server_type = "bx11"
            ipv6_only = 0
            additional_ipv4 = 0
            backup = 0
        }
    }
}

resource "hcloud_server" "servers" {
    for_each = local.server_config

    name = each.key
    server_type = each.value.server_type
    image = "debian-12"
    location = "hel1"
    ssh_keys = ["symbiont laptop key"]

    public_net {
        ipv4_enabled = each.value.ipv6_only == 1 ? false : true
        ipv6_enabled = true
    }

    backups = each.value.backup == 1 ? true : false
}

resource "hcloud_server_network" "ipv6" {
    for_each = { for k, v in local.server_config : k => v if v.ipv6_only == 1 }
    server_id  = hcloud_server.servers[each.key].id
    network_id = hcloud_network.this.id
}

resource "hcloud_floating_ip" "additional_ipv4" {
    for_each = { for k, v in local.server_config : k => v if v.additional_ipv4 == 1 }
    type = "ipv4"
    server_id = hcloud_server.servers[each.key].id
}

resource "hcloud_network" "this" {
    name = "private-network"
    ip_range = "10.0.0.0/24"
}

resource "hcloud_load_balancer" "app_lb" {
    name = "app-load-balancer"
    location = "hel1"
    load_balancer_type = "lb11"
}

resource "hcloud_load_balancer_target" "app_targets" {
    for_each = { for k, v in local.server_config : k => v if k == "apps1" || k == "apps2" || k == "apps3" }
    load_balancer_id = hcloud_load_balancer.app_lb.id
    type = "server"
    server_id = hcloud_server.servers[each.key].id
}

output "ip_addresses" {
    value = {
        for s in hcloud_server.servers : s.name => concat(
            [
                s.ipv4_address != "" ? s.ipv4_address : null,
                s.ipv6_address
            ],
            [for ip in hcloud_floating_ip.additional_ipv4 : ip.ip_address if ip.server_id == s.id]
        )
    }
}
