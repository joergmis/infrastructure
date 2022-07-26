job "voip" {
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

  group "voip" {
    count = 1
    network {
      port "http" {}
    }
    service {
      name = "voip"
      port = "http"
    }
    task "voip" {
      driver = "docker"
      config {
        network_mode = "host"
        image        = "registry.gitlab.com/tiny-rocket/itfactory-ag/voip:${hash}"
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
