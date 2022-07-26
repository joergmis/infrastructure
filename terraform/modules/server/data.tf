data "digitalocean_droplet_snapshot" "packer" {
  name_regex  = "tinyrocket-*"
  region      = "fra1"
  most_recent = true
}

