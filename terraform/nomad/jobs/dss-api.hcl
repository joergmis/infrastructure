job "dss-api" {
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

  group "dss-api" {
    count = 1
    network {
      port "http" {}
    }
    service {
      name = "dss-api"
      port = "http"

      check {
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }
    task "dss-api" {
      driver = "docker"
      config {
        network_mode = "host"
        image        = "registry.gitlab.com/tiny-rocket/dreiseenstafette/api:${hash}"
        ports        = ["http"]
        args = []
        volumes = []
        auth {
          username = "${gitlab_user}"
          password = "${gitlab_deploy_token}"
        }
      }
    }
  }
}
