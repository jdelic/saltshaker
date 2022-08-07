variable "hcloud_token" {
    sensitive = true
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
    token = var.hcloud_token
}

