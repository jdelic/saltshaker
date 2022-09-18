variable "hcloud_token" {
    sensitive = true
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
    token = var.hcloud_token
}

resource "hcloud_server" "saltmaster" {
    name        = "saltmaster"
    image       = "debian-11"
    server_type = ""

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }
}

resource "hcloud_server" "db" {
    name        = "db"
    image       = "debian-11"
    server_type = ""

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }
}

resource "hcloud_server" "dev" {
    name        = "dev"
    image       = "debian-11"
    server_type = ""

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }
}

resource "hcloud_server" "mail" {
    name        = "mail"
    image       = "debian-11"
    server_type = ""

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }
}

resource "hcloud_server" "mail" {
    name        = "mail"
    image       = "debian-11"
    server_type = ""

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }
}

resource "hcloud_server" "mail" {
    name        = "mail"
    image       = "debian-11"
    server_type = ""

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }
}

resource "hcloud_server" "mail" {
    name        = "mail"
    image       = "debian-11"
    server_type = ""

    public_net {
        ipv4_enabled = true
        ipv6_enabled = true
    }
}
