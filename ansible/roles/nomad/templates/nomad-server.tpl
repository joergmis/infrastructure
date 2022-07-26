datacenter = "dc1"
data_dir   = "/opt/nomad"

addresses {
  http = "{{ ansible_default_ipv4.address }}"
  rpc  = "{{ ansible_default_ipv4.address }}"
  serf = "{{ ansible_default_ipv4.address }}"
}

server {
  enabled          = true
  bootstrap_expect = 3
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

vault {
  enabled = true
  address = "http://vault.consul.service:8200"
  token = "{{ vault_token }}"
}