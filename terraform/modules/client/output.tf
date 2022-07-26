# the outputs can be referenced by the parent module
output "names" {
  value = digitalocean_droplet.client[*].name
}

output "ips" {
  value = digitalocean_droplet.client[*].ipv4_address
}

output "ips_private" {
  value = digitalocean_droplet.client[*].ipv4_address_private
}

output "urns" {
  value = digitalocean_droplet.client[*].urn
}

output "ids" {
  value = digitalocean_droplet.client[*].id
}

