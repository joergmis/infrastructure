job "voip-frontend" {
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

  group "voip-frontend" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name = "voip-frontend"
      port = "http"
    }

    task "voip-frontend" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "registry.gitlab.com/tiny-rocket/itfactory-ag/voip-frontend:${hash}"
        ports        = ["http"]
        args = []

        volumes = [
          "local/nginx.conf:/etc/nginx/nginx.conf",
        ]

        auth {
          username = "${gitlab_user}"
          password = "${gitlab_deploy_token}"
        }
      }

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

  server {
    listen {{ env "NOMAD_PORT_http" }};
    server_name  voipui;
    root   /usr/share/nginx/html;
		
    location /itfactory/voip/ui/ {
      try_files $uri $uri/ /itfactory/voip/ui/index.html;
    }
  }
}
EOF

        destination = "local/nginx.conf"
      }
    }
  }
}
