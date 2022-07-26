resource "digitalocean_droplet" "server" {
  image  = data.digitalocean_droplet_snapshot.packer.id
  count  = var.number
  name   = "${var.name}-${var.environment}-${count.index + 1}"
  region = var.region
  size   = "s-1vcpu-1gb"
  tags   = ["consul-server"]
}
