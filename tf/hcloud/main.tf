terraform {
    required_providers {
        hcloud = {
            source  = "hetznercloud/hcloud"
            version = "> 1.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "> 3.6.0"
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
            server_type = "cx23"
            backup = 1
            additional_ipv4 = 0
            additional_ipv6 = 0
            ipv6_only = 1
            internal_only = 1
            desired_count_of_ipv6_ips = 0
            desired_count_of_additional_ipv6_ips = 0
            ptr = null
            roles = ["database", "vault", "authserver", "consulserver"]
            firewall_ids = null
            volumes = {
                "dbdata" = {
                    size = 10
                    mountpoint = "/secure"
                }
            }
        }
        "mail.indevelopment.de" = {
            server_type = "cx23"
            backup = 1
            additional_ipv4 = 1
            additional_ipv6 = 0
            ipv6_only = 0
            internal_only = 0
            desired_count_of_ipv6_ips = 2
            desired_count_of_additional_ipv6_ips = 0
            ptr = "mail.indevelopment.de"
            roles = ["mail"]
            firewall_ids = [hcloud_firewall.mail.id, hcloud_firewall.ping.id]
            volumes = {
                "maildata" = {
                    size = 40
                    mountpoint = "/secure"
                }
            }
        }
        "dev.maurusnet.internal" = {
            server_type = "cx33"
            backup = 0
            additional_ipv4 = 0
            additional_ipv6 = 0
            ipv6_only = 1
            internal_only = 1
            desired_count_of_ipv6_ips = 0
            desired_count_of_additional_ipv6_ips = 0
            ptr = null
            roles = ["dev", "buildserver", "buildworker", "consulserver", "docker-registry"]
            firewall_ids = null
            volumes = {}
        }
        "apps1.maurusnet.internal" = {
            server_type = "cx23"
            backup = 0
            additional_ipv4 = 0
            additional_ipv6 = 0
            ipv6_only = 1
            internal_only = 1
            desired_count_of_ipv6_ips = 0
            desired_count_of_additional_ipv6_ips = 0
            ptr = null
            roles = ["apps", "nomadserver"]
            firewall_ids = null
            volumes = {}
        }
        "apps2.maurusnet.internal" = {
            server_type = "cx23"
            backup = 0
            additional_ipv4 = 0
            additional_ipv6 = 0
            ipv6_only = 1
            internal_only = 1
            desired_count_of_ipv6_ips = 0
            desired_count_of_additional_ipv6_ips = 0
            ptr = null
            roles = ["apps", "nomadserver"]
            firewall_ids = null
            volumes = {}
        }
        "apps3.maurusnet.internal" = {
            server_type = "cx23"
            backup = 0
            additional_ipv4 = 0
            additional_ipv6 = 0
            ipv6_only = 1
            internal_only = 1
            desired_count_of_ipv6_ips = 0
            desired_count_of_additional_ipv6_ips = 0
            ptr = null
            roles = ["apps", "nomadserver"]
            firewall_ids = null
            volumes = {}
        }
        "lb1.indevelopment.de" = {
            server_type = "cx23"
            backup = 0
            additional_ipv4 = 0
            additional_ipv6 = 0
            ipv6_only = 0
            internal_only = 0
            desired_count_of_ipv6_ips = 1
            desired_count_of_additional_ipv6_ips = 0
            ptr = null
            roles = ["loadbalancer"]
            firewall_ids = [hcloud_firewall.web.id, hcloud_firewall.ping.id]
            volumes = {}
        }
    }

    volumes = merge([
        for server_name, server_conf in local.server_config : {
            for v_name, vol in server_conf.volumes :
                v_name => {
                    name = "vol-${v_name}"
                    server = server_name
                    size = vol.size
                    mountpoint = vol.mountpoint
                } if length(server_conf.volumes) > 0
        }
    ]...)
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

resource "random_password" "storage_box_root" {
    length = 32
    special = true
    override_special = "$%+-#"
    min_special = 1
    upper = true
    min_upper = 1
    lower = true
    min_lower = 1
    min_numeric = 1
}

resource "hcloud_storage_box" "backup-box" {
    name = "backup-box"
    storage_box_type = "bx11"
    location = "hel1"

    password = random_password.storage_box_root.result

    access_settings = {
        ssh_enabled = true
    }

    ssh_keys = [hcloud_ssh_key.jm_hades.public_key, hcloud_ssh_key.jm_parasite.public_key]
    delete_protection = false

    depends_on = [hcloud_ssh_key.jm_hades, hcloud_ssh_key.jm_parasite]
}

# resource "random_password" "saltmaster_backup_account" {
#     length = 32
#     special = true
#     override_special = "$%+-#"
#     min_special = 1
#     upper = true
#     min_upper = 1
#     lower = true
#     min_lower = 1
#     min_numeric = 1
# }
#
# resource "hcloud_storage_box_subaccount" "saltmaster" {
#     name = "sbox-saltmaster"
#     storage_box_id = hcloud_storage_box.backup-box.id
#     home_directory = "/server/saltmaster/"
#     password = random_password.saltmaster_backup_account.result
#
#     depends_on = [hcloud_storage_box.backup-box]
# }

resource "hcloud_server" "saltmaster" {
    name = "symbiont.indevelopment.de"
    server_type = "cx23"
    image = "debian-13"
    location = "hel1"
    ssh_keys = ["jonas@parasite", "jonas@hades"]

    network {
        network_id = hcloud_network.internal.id
        # work around https://github.com/hetznercloud/terraform-provider-hcloud/issues/650
        alias_ips = []
    }

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }

    user_data = templatefile("${path.module}/../salt-master.cloud-init.yml", {
        saltmaster_config = file("${path.module}/../../etc/salt-master/master.d/saltshaker.conf")
        hostname = "symbiont.indevelopment.de",
        server_type = "cx22",
        backup_server = hcloud_storage_box.backup-box.server,
        backup_username = hcloud_storage_box.backup-box.username,
        backup_password = random_password.storage_box_root.result,
        backup_homedir = "/server/saltmaster/"
    })

    backups = true

    firewall_ids = [hcloud_firewall.ssh.id, hcloud_firewall.ping.id]

    # important as per hcloud docs as there's a race condition otherwise
    depends_on = [hcloud_network_subnet.internal-subnet, hcloud_firewall.ssh, hcloud_storage_box.backup-box]
}

# resource "random_password" "backup_accounts" {
#     for_each = local.server_config
#
#     length = 32
#     special = true
#     override_special = "$%+-#"
#     min_special = 1
#     upper = true
#     min_upper = 1
#     lower = true
#     min_lower = 1
#     min_numeric = 1
# }
#
# resource "hcloud_storage_box_subaccount" "serveraccounts" {
#     for_each = local.server_config
#
#     name = "sbox-${each.key}"
#     storage_box_id = hcloud_storage_box.backup-box.id
#     home_directory = "/server/${each.key}/"
#     password = random_password.backup_accounts[each.key].result
#
#     access_settings = {
#         ssh_enabled = true
#     }
#
#     depends_on = [hcloud_storage_box.backup-box]
# }

resource "hcloud_volume" "disks" {
    for_each = local.volumes
    name = each.value.name
    size = each.value.size
    format = "ext4"
    location = "hel1"
}

resource "hcloud_volume_attachment" "disk_attachments" {
    for_each = local.volumes
    server_id = hcloud_server.servers[each.value.server].id
    volume_id = hcloud_volume.disks[each.key].id
}

resource "hcloud_server" "servers" {
    for_each = local.server_config

    name = each.key
    server_type = each.value.server_type
    image = "debian-13"
    location = "hel1"
    ssh_keys = ["jonas@parasite", "jonas@hades"]

    network {
        network_id = hcloud_network.internal.id
        # work around https://github.com/hetznercloud/terraform-provider-hcloud/issues/650
        alias_ips = []
    }

    public_net {
        ipv4_enabled = each.value.ipv6_only == 1 ? false : true
        ipv6_enabled = each.value.internal_only == 1 ? false : true
    }

    user_data = templatefile("${path.module}/../salt-minion.cloud-init.yml", {
                    saltmaster_ip = flatten(hcloud_server.saltmaster.network.*.ip)[0],
                    additional_ipv4 = each.value.additional_ipv4 == 1 ? hcloud_floating_ip.additional_ipv4[each.key].ip_address : false,
                    additional_ipv6 = each.value.additional_ipv6 == 1 ? hcloud_floating_ip.additional_ipv6[each.key].ip_address : false,
                    roles = lookup(each.value, "roles", []),
                    ipv6_only = each.value.ipv6_only == 1,
                    desired_count_of_ipv6_ips = each.value.desired_count_of_ipv6_ips,
                    desired_count_of_additional_ipv6_ips = each.value.desired_count_of_additional_ipv6_ips,
                    hostname = each.key,
                    server_type = each.value.server_type,
                    backup_server = hcloud_storage_box.backup-box.server,
                    backup_username = hcloud_storage_box.backup-box.username,
                    backup_password = random_password.storage_box_root.result,
                    backup_homedir = "/server/${each.key}/",
                    volumes = { for vol_name, vol_conf in each.value.volumes: vol_name => merge(
                        vol_conf,
                        {
                            "id" : hcloud_volume.disks[vol_name].id
                        }
                    )}
                })

    lifecycle {
        ignore_changes = [user_data]
    }

    backups = each.value.backup == 1 ? true : false

    firewall_ids = each.value.firewall_ids

    # important as per hcloud docs as there's a race condition otherwise
    depends_on = [hcloud_network_route.nat-route, hcloud_network_subnet.internal-subnet, hcloud_server.saltmaster]
}

resource "hcloud_floating_ip" "additional_ipv4" {
    for_each = { for k, v in local.server_config : k => v if v.additional_ipv4 == 1 }
    name = "ipv4-${each.key}"
    type = "ipv4"
    home_location = "hel1"
}

resource "hcloud_floating_ip_assignment" "additional_ipv4" {
    for_each  = hcloud_floating_ip.additional_ipv4
    server_id = hcloud_server.servers[trimprefix(each.key, "ipv4-")].id
    floating_ip_id = each.value.id
}

resource "hcloud_floating_ip" "additional_ipv6" {
    for_each = { for k, v in local.server_config : k => v if v.additional_ipv6 == 1 }
    name = "ipv6-${each.key}"
    type = "ipv6"
    home_location = "hel1"
}

resource "hcloud_floating_ip_assignment" "additional_ipv6" {
    for_each  = hcloud_floating_ip.additional_ipv6
    server_id = hcloud_server.servers[trimprefix(each.key, "ipv6-")].id
    floating_ip_id = each.value.id
}

resource "hcloud_firewall" "ping" {
    name = "ping"

    rule {
        direction = "in"
        protocol  = "icmp"
        source_ips = ["0.0.0.0/0", "::/0"]
    }
}

resource "hcloud_firewall" "ssh" {
    name = "ssh"

    rule {
        direction = "in"
        protocol  = "tcp"
        port      = 22
        source_ips = ["0.0.0.0/0", "::/0"]
    }
}

resource "hcloud_firewall" "mail" {
    name = "mail"

    rule {
        direction = "in"
        protocol  = "tcp"
        port      = 25
        source_ips = ["0.0.0.0/0", "::/0"]
    }

    rule {
        direction = "in"
        protocol  = "tcp"
        port      = 465
        source_ips = ["0.0.0.0/0", "::/0"]
    }
}

resource "hcloud_firewall" "web" {
    name = "web"

    rule {
        direction = "in"
        protocol  = "tcp"
        port      = 80
        source_ips = ["0.0.0.0/0", "::/0"]
    }

    rule {
        direction = "in"
        protocol  = "tcp"
        port      = 443
        source_ips = ["0.0.0.0/0", "::/0"]
    }
}

resource "hcloud_ssh_key" "jm_parasite" {
    name = "jonas@parasite"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuRkuMdRdZ8aNZu6X8qlAfrVWbRP2Bi9M96I2zdZ31O jonas@parasite"
}

resource "hcloud_ssh_key" "jm_hades" {
    name       = "jonas@hades"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHS6w4Jzel7ef0jxiLG7s+8hvOaDx0SLWXr9PhC3ZnIb jonas@hades"
}

output "ip_addresses" {
    value = {
        for s in merge({"symbiont.indevelopment.de" = hcloud_server.saltmaster}, hcloud_server.servers) : s.name => concat(
            s.ipv4_address != "" ? [s.ipv4_address] : [],
            s.ipv6_address != "" ? [s.ipv6_address] : [],
            flatten(s.network.*.ip),
            [for ip in hcloud_floating_ip.additional_ipv4 : ip.ip_address if ip.name == "ipv4-${s.name}"],
            [for ip in hcloud_floating_ip.additional_ipv6 : ip.ip_address if ip.name == "ipv6-${s.name}"]
        )
    }
}

output "storage_box_info" {
    value = {
        server = hcloud_storage_box.backup-box.server,
        username = hcloud_storage_box.backup-box.username,
        password = random_password.storage_box_root.result
    }
    sensitive = true
}

output "volumes" {
    value = local.volumes
}