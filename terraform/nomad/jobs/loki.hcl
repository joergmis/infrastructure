job "loki" {
  datacenters = ["dc1"]
  type        = "service"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "30s"
    auto_revert      = true
  }

  reschedule {
    attempts       = 15
    interval       = "30m"
    delay          = "30s"
    delay_function = "exponential"
    max_delay      = "120s"
    unlimited      = false
  }

  group "loki" {
    count = 1

    network {
      port "loki"{}
      port "loki_grpc"{}
    }

    service {
      name = "loki"
      port = "loki"
      tags = ["monitoring"]

      # TODO: add service check
      # check {}
    }

    task "loki" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "grafana/loki:2.3.0"
        ports        = ["loki"]

        volumes = [
          "local/loki.yml:/etc/loki/local-config.yaml",
        ]

        # TODO: use vault to provide the secrets
        auth {
          username = "${gitlab_user}"
          password = "${gitlab_deploy_token}"
        }
      }

      template {
        data = <<EOH
auth_enabled: false

server:
  http_listen_port: {{ env "NOMAD_PORT_loki" }}
  grpc_listen_port: {{ env "NOMAD_PORT_loki_grpc" }}

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
  - from: 2020-05-15
    store: boltdb
    object_store: filesystem
    schema: v11
    index:
      prefix: index_
      period: 168h

storage_config:
  boltdb:
    directory: /tmp/loki/index

  filesystem:
    directory: /tmp/loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
EOH

        destination = "local/loki.yml"
      }

      env {
        JAEGER_AGENT_HOST    = "tempo.service.consul"
        JAEGER_TAGS          = "cluster=nomad"
        JAEGER_SAMPLER_TYPE  = "probabilistic"
        JAEGER_SAMPLER_PARAM = "1"
      }

      # TODO: add resources
      # resources {}
    }
  }
}
