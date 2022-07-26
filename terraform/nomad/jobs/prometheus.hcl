job "prometheus" {
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

  group "prometheus" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name = "prometheus"
      port = "http"

      # TODO: add service check
      # check {}
    }

    task "prometheus" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "prom/prometheus:latest"
        ports        = ["http"]

        args = [
          "--web.listen-address=:${NOMAD_PORT_http}",
          "--config.file=/local/prometheus.yml",
        ]

        # TODO: use vault to provide the secrets
        auth {
          username = "${gitlab_user}"
          password = "${gitlab_deploy_token}"
        }
      }

      template {
        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s

scrape_configs:
  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_http" }}:8500'
      services: ['nomad-client', 'nomad']
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep
    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

  - job_name: 'consul_metrics'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_http" }}:8500'
      services: ['consul-client', 'consul']
    relabel_configs:
    - source_labels: [__meta_consul_service_metadata_external_source]
      target_label: source
      regex: (.*)
      replacement: '$1'
    - source_labels: [__meta_consul_service_id]
      regex: '_nomad-task-(.*)-(.*)-(.*)-(.*)'
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
EOH

        destination = "/local/prometheus.yml"
      }

      # TODO: add resources
      # resources {}
    }
  }
}
