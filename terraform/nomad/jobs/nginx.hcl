job "nginx" {
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

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 80
      }

      port "https" {
        static = 443
      }

      port "mqtt" {
        static = 1883
      }
    }

    service {
      name = "nginx"
      port = "https"

      # TODO: add service check
      # check {}
    }

    task "nginx" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "nginx:latest"
        ports        = ["http", "https", "mqtt"]

        volumes = [
          "local/nginx.conf:/etc/nginx/nginx.conf",
        ]

        # TODO: use vault to provide the secrets
        auth {
          username = "${gitlab_user}"
          password = "${gitlab_deploy_token}"
        }
      }

      env {}

      template {
        data = <<EOF
events {
  worker_connections  1024;
}

http {
  include       mime.types;
  default_type  application/octet-stream;
  sendfile        on;
  keepalive_timeout  65;
  client_max_body_size 20M;

  map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
  }

  server {
    listen       80;
    server_name  tiny-rocket.ch;

    {{ if service "grafana" }}
    # grafana with http
    location /infra/v1/grafana {
      {{ with index (service "grafana") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }};
      proxy_set_header    Host              $host;
      proxy_set_header    X-Real-IP         $remote_addr;
      proxy_set_header    X-Forwarded-for   $proxy_add_x_forwarded_for;
      proxy_set_header    X-Forwarded-Proto "https";
      proxy_set_header    Connection        $connection_upgrade;
      proxy_set_header    Upgrade           $http_upgrade;
      {{ end }}
    }
    {{ end }}

    {{ if service "tinyrocket" }}
    # voip ordering service
    location / {
      {{ with index (service "tinyrocket") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/;
      {{ end }}
    }
    {{ end }}

    {{ if service "voip" }}
    # voip ordering service
    location /itfactory/voip/api/ {
      {{ with index (service "voip") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/;
      {{ end }}
    }
    {{ end }}

    {{ if service "voip-frontend" }}
    # voip-ui ordering service
    location /itfactory/voip/ui {
      {{ with index (service "voip-frontend") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/itfactory/voip/ui;
      {{ end }}
    }
    {{ end }}

    {{ if service "dss" }}
    # voip-ui ordering service
    location /dreiseenstafette/area {
      {{ with index (service "dss") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/dreiseenstafette/area;
      {{ end }}
    }
    {{ end }}

    {{ if service "dss-counter" }}
    location /counter {
      {{ with index (service "dss-counter") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/counter;
      {{ end }}
    }
    {{ end }}

    {{ if service "dss-api" }}
    # voip ordering service
    location /dreiseenstafette/api/ {
      {{ with index (service "dss-api") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/;
      {{ end }}
    }
    {{ end }}

    {{ if service "server" }}
    location /gifts/api/ {
      {{ with index (service "server") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/;
      {{ end }}
    }
    {{ end }}

    {{ if service "gifts-frontend" }}
    # voip-ui ordering service
    location /gifts/ui {
      {{ with index (service "gifts-frontend") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/gifts/ui;
      {{ end }}
    }
    {{ end }}

    {{ if service "ecw-frontend" }}
    # voip-ui ordering service
    location /ecw/ui {
      {{ with index (service "ecw-frontend") 0 }}
      proxy_pass http://{{ .Address }}:{{ .Port }}/ecw/ui;
      {{ end }}
    }
    {{ end }}
  }
}
EOF

        destination = "local/nginx.conf"
      }

      # TODO: add resources
      # resources {}
    }
  }
}
