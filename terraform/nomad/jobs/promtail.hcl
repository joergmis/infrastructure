job "promtail" {
  datacenters = ["dc1"]
  type        = "system"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "30s"
    auto_revert      = true
    canary           = 1
  }

  group "promtail" {
    count = 1

    network {
      port "http" {}
    }

    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }

    task "promtail" {
      driver = "docker"

      env {
        HOSTNAME = "${attr.unique.hostname}"
      }

      template {
        data = <<EOTC
positions:
  filename: /data/positions.yaml

clients:
  - url: {{ range service "loki" }}http://{{ .Address }}:{{ .Port }}/loki/api/v1/push{{ end }}

scrape_configs:
- job_name: 'nomad-logs'
  consul_sd_configs:
    - server: '{{ env "NOMAD_IP_http" }}:8500'
  relabel_configs:
    - source_labels: [__meta_consul_node]
      target_label: __host__
    - source_labels: [__meta_consul_service_metadata_external_source]
      target_label: source
      regex: (.*)
      replacement: '$1'
    - source_labels: [__meta_consul_service_id]
      regex: '_nomad-task-([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})-.*'
      target_label:  'task_id'
      replacement: '$1'
    - source_labels: [__meta_consul_tags]
      regex: ',(app|monitoring),'
      target_label:  'group'
      replacement:   '$1'
    - source_labels: [__meta_consul_service]
      target_label: job
    - source_labels: ['__meta_consul_node']
      regex:         '(.*)'
      target_label:  'instance'
      replacement:   '$1'
    - source_labels: [__meta_consul_service_id]
      regex: '_nomad-task-([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})-.*'
      target_label:  '__path__'
      replacement: '/nomad/alloc/$1/alloc/logs/*std*.{?,??}'
EOTC

        destination = "/local/promtail.yml"
      }

      config {
        image = "grafana/promtail"
        ports = ["http"]

        args = [
          "-config.file=/local/promtail.yml",
          "-server.http-listen-port=${NOMAD_PORT_http}",
        ]

        volumes = [
          "/data/promtail:/data",
          "/opt/nomad/:/nomad/",
        ]
      }

      resources {
        cpu    = 50
        memory = 100
      }

      service {
        name = "promtail"
        port = "http"
        tags = ["monitoring"]

        check {
          name     = "Promtail HTTP"
          type     = "http"
          path     = "/targets"
          interval = "5s"
          timeout  = "2s"

          check_restart {
            limit           = 2
            grace           = "60s"
            ignore_warnings = false
          }
        }
      }
    }
  }
}
