job "ecw-frontend" {
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

  group "ecw-frontend" {
    count = 1

    network {
      port "http" {}
    }

    service {
      name = "ecw-frontend"
      port = "http"
    }

    task "ecw-frontend" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "registry.gitlab.com/tiny-rocket/ecw:${hash}"
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
    server_name  giftsui;
    root   /usr/share/nginx/html;
		
    location /ecw/ui/ {
      try_files $uri $uri/ /ecw/ui/index.html;
    }
  }
}
EOF

        destination = "local/nginx.conf"
      }
    }
  }
}
