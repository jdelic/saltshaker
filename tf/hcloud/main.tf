provider "hcloud" {
  token = "<your_api_token>"
}

locals {
  server_config = {
    saltmaster = {
      server_type = "cx11"
      backup      = false
      additional_ipv4 = false
      ipv6_only = true
    }
    db = {
      server_type = "cx21"
      backup      = true
      additional_ipv4 = false
      ipv6_only = true
    }
    dev = {
      server_type = "cx31"
      backup      = false
      additional_ipv4 = false
      ipv6_only = true
    }
    mail = {
      server_type = "cpx21"
      backup      = true
      additional_ipv4 = true
      ipv6_only = false
    }
    apps1 = {
      server_type = "cx21"
      backup      = false
      additional_ipv4 = false
      ipv6_only = true
    }
    apps2 = {
      server_type = "cx21"
      backup      = false
      additional_ipv4 = false
      ipv6_only = true
    }
    apps3 = {
      server_type = "cx21"
      backup      = false
      additional_ipv4 = false
      ipv6_only = true
    }
    backup = {
      server_type = "bx11"
    }
  }
}

resource "hcloud_server" "this" {
  for_each = local.server_config

  name         = each.key
  server_type  = each.value.server_type
  image        = "debian-11"
  location     = "hel1"
  ssh_keys     = ["<your_ssh_key_name>"]

  public_net {
    ipv4 = !each.ipv6_only
    ipv6 = true
  }

  backup_window = each.value.backup ? "22-02" : null
}

resource "hcloud_server_network" "ipv6" {
  for_each = { for k, v in local.server_config : k => v if v.ipv6_only }

  server_id  = hcloud_server.this[each.key].id
  network_id = hcloud_network.this.id
}

resource "hcloud_floating_ip" "mail_additional_ipv4" {
  type      = "ipv4"
  server_id = hcloud_server.this["mail"].id
}

resource "hcloud_network" "this" {
  name         = "private-network"
  ip_range     = "10.0.0.0/16"
}

resource "hcloud_load_balancer" "app_lb" {
  name       = "app-load-balancer"
  location   = "hel1"
  load_balancer_type = "lb11"
}

resource "hcloud_load_balancer_target" "app_targets" {
  for_each = { for k, v in local.server_config : k => v if k == "apps1" || k == "apps2" || k == "apps3" }

  load_balancer_id = hcloud_load_balancer.app_lb.id
  type             = "server"
  server_id        = hcloud_server.this[each.key].id
}

output "servers" {
  value = {
    for s in hcloud_server.this : s.name => {
      ipv4_address = s.name == "mail" ? hcloud_floating_ip.mail_additional_ipv4.ip : s.ipv4_address
      ipv6_address = s.ipv6_address
    }
  }
}
