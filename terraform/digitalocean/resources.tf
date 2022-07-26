# ==============================================================================
# Items that are already there and we don't want to change / delete.
# ==============================================================================

data "digitalocean_project" "prod" {
  name = "tiny-rocket infrastructure"
}

data "digitalocean_loadbalancer" "lb" {
  name = "tiny-rocket-ch-loadbalancer"
}

resource "digitalocean_project_resources" "droplets" {
  project = data.digitalocean_project.prod.id
  resources = concat(
    module.client.urns,
    module.server.urns,
  )
}

resource "digitalocean_firewall" "web" {
  name = "tiny-rocket-firewall"

  droplet_ids = [
    module.server.ids[0],
    module.server.ids[1],
    module.server.ids[2],
    module.client.ids[0],
    module.client.ids[1],
    module.client.ids[2],
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # This port will be managed by ansible with UFW.
  inbound_rule {
    protocol         = "tcp"
    port_range       = "4646"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  # This port will be managed by ansible with UFW.
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8500"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "1-65535"
    source_addresses = [
      data.digitalocean_loadbalancer.lb.ip,
      module.server.ips[0],
      module.server.ips[1],
      module.server.ips[2],
      module.client.ips[0],
      module.client.ips[1],
      module.client.ips[2],
      "10.114.0.0/20", # fra1 vpc
    ]
  }

  inbound_rule {
    protocol   = "udp"
    port_range = "1-65535"
    source_addresses = [
      data.digitalocean_loadbalancer.lb.ip,
      module.server.ips[0],
      module.server.ips[1],
      module.server.ips[2],
      module.client.ips[0],
      module.client.ips[1],
      module.client.ips[2],
      "10.114.0.0/20", # fra1 vpc
    ]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}


# ==============================================================================
# Stateful droplet -> for the reverse proxy, the database and so on.
# TODO: use CSI
# ==============================================================================

data "digitalocean_droplet_snapshot" "packer" {
  name_regex  = "tinyrocket-*"
  region      = "fra1"
  most_recent = true
}

# ==============================================================================
# The server and clients have different needs - we can use different base images
# in the future.
# ==============================================================================

module "server" {
  source = "../modules/server"
  number = 3
  region = var.region
}

module "client" {
  source = "../modules/client"
  number = 3
  region = var.region
}

# ==============================================================================
# Create the necessary files for ansible.
# ==============================================================================

resource "local_file" "inventory" {
  filename = "${path.module}/../../ansible/${var.environment}/hosts"
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      servers = zipmap(module.server.names, module.server.ips)
      clients = zipmap(module.client.names, module.client.ips)
  })
}

resource "local_file" "config" {
  filename = "${path.module}/../../ansible/ansible.cfg"
  content = templatefile("${path.module}/templates/ansible.tpl",
    {
      environment = var.environment
  })
}

# ==============================================================================
# Set the ip for the nomad provider
# the floating IP unfortunately does not seem to work
# ==============================================================================

resource "local_file" "provider" {
  filename = "${path.module}/../nomad/provider.tf"
  content = templatefile("${path.module}/templates/provider.tpl",
    {
      ip = module.server.ips[0]
  })
}

