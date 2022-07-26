resource "nomad_job" "grafana" {
  jobspec = file("${path.module}/jobs/grafana.hcl")
  depends_on = [
    nomad_job.loki,
    nomad_job.prometheus,
    nomad_job.tempo,
  ]
}

resource "nomad_job" "nginx" {
  jobspec = file("${path.module}/jobs/nginx.hcl")
}

resource "nomad_job" "loki" {
  jobspec = file("${path.module}/jobs/loki.hcl")
}

resource "nomad_job" "promtail" {
  jobspec = file("${path.module}/jobs/promtail.hcl")
}

resource "nomad_job" "prometheus" {
  jobspec = file("${path.module}/jobs/prometheus.hcl")
}

resource "nomad_job" "tempo" {
  jobspec = file("${path.module}/jobs/tempo.hcl")
}

# ============================================================================

variable "gitlab_username" {}

variable "gitlab_deploy_token" {}

variable "voip_hash" {
  default = "latest"
}

resource "nomad_job" "voip" {
  jobspec = templatefile(
    "${path.module}/jobs/voip.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.voip_hash
    }
  )
}

variable "voip_frontend_hash" {
  default = "latest"
}

resource "nomad_job" "voip-frontend" {
  jobspec = templatefile(
    "${path.module}/jobs/voip-frontend.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.voip_frontend_hash
    }
  )
}

variable "tinyrocket_hash" {
  default = "latest"
}

resource "nomad_job" "tinyrocket" {
  jobspec = templatefile(
    "${path.module}/jobs/tinyrocket.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.tinyrocket_hash
    }
  )
}

variable "dss_hash" {
  default = "latest"
}

resource "nomad_job" "dss" {
  jobspec = templatefile(
    "${path.module}/jobs/dss.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.dss_hash
    }
  )
}

variable "dss_api_hash" {
  default = "latest"
}

resource "nomad_job" "dss-api" {
  jobspec = templatefile(
    "${path.module}/jobs/dss-api.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.dss_api_hash
    }
  )
}

variable "dss_counter_hash" {
  default = "latest"
}

resource "nomad_job" "dss-counter" {
  jobspec = templatefile(
    "${path.module}/jobs/dss-counter.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.dss_counter_hash
    }
  )
}

variable "server_hash" {
  default = "latest"
}

resource "nomad_job" "server" {
  jobspec = templatefile(
    "${path.module}/jobs/server.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.server_hash
    }
  )
}

variable "ecw_frontend_hash" {
  default = "latest"
}

resource "nomad_job" "ecw-frontend" {
  jobspec = templatefile(
    "${path.module}/jobs/ecw-frontend.hcl",
    {
      gitlab_user         = var.gitlab_username
      gitlab_deploy_token = var.gitlab_deploy_token
      hash                = var.ecw_frontend_hash
    }
  )
}

