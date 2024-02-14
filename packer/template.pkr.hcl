source "digitalocean" "image"{
    image = "ubuntu-20-04-x64"
    region = "fra1"
    monitoring = "true"
    ssh_username = "root"
    size = "s-1vcpu-1gb"
    snapshot_name = "tinyrocket-{{timestamp}}"
}

build {
    sources = [
        "source.digitalocean.image"
    ]

    provisioner "ansible" {
        playbook_file = "./setup.yml"
        # https://github.com/hashicorp/packer/issues/11783#issuecomment-1137052770
        extra_arguments = [ "--scp-extra-args", "'-O'" ]
    }
}
