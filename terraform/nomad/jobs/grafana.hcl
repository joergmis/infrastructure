job "grafana" {
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

  group "grafana" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name = "grafana"
      port = "http"

      # TODO: add service check
      # check {}
    }

    task "grafana" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "grafana/grafana:8.1.5"
        ports        = ["http"]

        args = [
          "-config=/var/lib/grafana.ini",
        ]

        volumes = [
          "local/grafana.ini:/var/lib/grafana.ini",
          "local/ds.yml:/etc/grafana/provisioning/datasources/ds.yaml",
        ]

        auth {
          username = "${gitlab_user}"
          password = "${gitlab_deploy_token}"
        }
      }

      # TODO: add resources
      # resources {}

      env {
        TEST = "1"
      }
      template {
        data = <<EOF
[server]
protocol = http
http_port = {{ env "NOMAD_PORT_http" }}
root_url = https://tiny-rocket.ch/infra/v1/grafana
serve_from_sub_path = true
EOF

        destination = "local/grafana.ini"
      }

      template {
        data = <<EOTC
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: {{ range service "prometheus" }}{{ .Address }}:{{ .Port }}{{ end }}
  - name: Loki
    type: loki
    access: proxy
    url: {{ range service "loki" }}{{ .Address }}:{{ .Port }}{{ end }}
    jsonData:
      httpHeaderName1: 'Connection'
      httpHeaderName2: 'Upgrade'
    secureJsonData:
      httpHeaderValue1: 'Upgrade'
      httpHeaderValue2: 'websocket'
  - name: Tempo
    type: tempo
    access: proxy
    url: {{ range service "tempo" }}{{ .Address }}:{{ .Port }}{{ end }}
EOTC

        destination = "/local/ds.yml"
      }
    }
  }
}
