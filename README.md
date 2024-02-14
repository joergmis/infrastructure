# Infrastructure

## Prerequisites

* install packer, terraform, ansible and ansible-playbook
* setup the env and secret files
    * `./ansible/vault.txt`
    * `./ansible/passwd`
    * `./vars.sh`
* packer
    * install packer plugin
        * `packer plugins install github.com/digitalocean/digitalocean`
        * `packer plugins install github.com/hashicorp/ansible`
    * setup packer: `packer init`
* terraform
    * setup terraform: `terraform init`

## Setup

* run packer to generate the base image
* setup digitalocean droplets with terraform
* run ansible to finish setup of the platforms
