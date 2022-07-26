# the outputs can be referenced by the parent module
output "names" {
  value = digitalocean_droplet.server[*].name
}

output "ips" {
  value = digitalocean_droplet.server[*].ipv4_address
}

output "ips_private" {
  value = digitalocean_droplet.server[*].ipv4_address_private
}

output "urns" {
  value = digitalocean_droplet.server[*].urn
}

output "ids" {
  value = digitalocean_droplet.server[*].id
}

