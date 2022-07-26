# generated with hashi-up

datacenter = "dc1"
data_dir   = "/opt/nomad"

addresses {
  http = "{{ ansible_default_ipv4.address }}"
  rpc  = "{{ ansible_default_ipv4.address }}"
  serf = "{{ ansible_default_ipv4.address }}"
}

client {
  enabled = true
}

telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}

plugin "docker" {
  config {
    volumes {
      enabled      = true
    }
  }
}

