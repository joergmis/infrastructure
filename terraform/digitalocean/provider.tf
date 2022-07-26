terraform {
  required_version = ">= 0.13"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.6.0"
    }
  }

  # use the gitlab http backend
  backend "http" {}
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {}

variable "environment" {
  default = "prod"
}

variable "region" {
  default = "fra1"
}
