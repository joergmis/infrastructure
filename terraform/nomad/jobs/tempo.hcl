job "tempo" {
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

  group "tempo" {
    count = 1

    network {
      port "tempo" {
        to = 3400
      }

      port "tempo_grpc" {}

      port "tempo_write" {
        to = 6832
      }
    }

    service {
      name = "tempo"
      port = "tempo"
      port = "tempo_write"
      port = "tempo_grpc"

      # TODO: add service check
      # check {}
    }

    task "tempo" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "grafana/tempo:latest"
        ports        = ["tempo", "tempo_write", "tempo_grpc"]

        args = [
          "-config.file=/local/tempo.yml",
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
server:
  http_listen_port: {{ env "NOMAD_PORT_tempo" }}
  grpc_listen_port: {{ env "NOMAD_PORT_tempo_grpc" }}

distributor:
  receivers:                           # this configuration will listen on all ports and protocols that tempo is capable of.
    jaeger:                            # the receives all come from the OpenTelemetry collector.  more configuration information can
      protocols:                       # be found there: https://github.com/open-telemetry/opentelemetry-collector/tree/main/receiver
        thrift_http:                   #
        grpc:                          # for a production deployment you should only enable the receivers you need!
        thrift_binary:
        thrift_compact:
    zipkin:
    otlp:
      protocols:
        http:
        grpc:
    opencensus:

ingester:
  trace_idle_period: 10s               # the length of time after a trace has not received spans to consider it complete and flush it
  max_block_bytes: 1_000_000           # cut the head block when it hits this size or ...
  max_block_duration: 5m               #   this much time passes

compactor:
  compaction:
    compaction_window: 1h              # blocks in this time window will be compacted together
    max_block_bytes: 100_000_000       # maximum size of compacted blocks
    block_retention: 1h
    compacted_block_retention: 10m

storage:
  trace:
    backend: local                     # backend configuration to use
    block:
      bloom_filter_false_positive: .05 # bloom filter false positive rate.  lower values create larger filters but fewer false positives
      index_downsample_bytes: 1000     # number of bytes per index record
      encoding: zstd                   # block encoding/compression.  options: none, gzip, lz4-64k, lz4-256k, lz4-1M, lz4, snappy, zstd
    wal:
      path: /tmp/tempo/wal             # where to store the the wal locally
      encoding: none                   # wal encoding/compression.  options: none, gzip, lz4-64k, lz4-256k, lz4-1M, lz4, snappy, zstd
    local:
      path: /tmp/tempo/blocks
    pool:
      max_workers: 100                 # the worker pool mainly drives querying, but is also used for polling the blocklist
      queue_depth: 10000
EOF

        destination = "local/tempo.yml"
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
