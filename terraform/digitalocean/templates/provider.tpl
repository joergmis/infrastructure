terraform {
  required_version = ">= 0.13"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.6.0"
    }

    nomad = {
      source = "hashicorp/nomad"
      version = ">= 1.4.13"
    }
  }

  backend "http" {}
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {}

variable "region" {
  default = "fra1"
}

data "digitalocean_droplet" "leader" {
  name = "leader-prod-1"
}

provider "nomad" {
  address = "http://${ip}:4646"
}
