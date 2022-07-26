# Infrastructure

> The goal is to provide a stack that enables people to easily add
> observability to the applications. It should be as simple and automated as 
> possible.

The current stack looks like this:

* [hashicorp nomad](https://www.nomadproject.io)
* [hashicorp consul](https://www.hashicorp.com/products/consul)
* [grafana loki](https://grafana.com/oss/loki/)
* [grafana tempo](https://grafana.com/oss/tempo/)
* [grafana prometheus](https://grafana.com/oss/prometheus/)
* [grafana](https://grafana.com/grafana/)

## Architecture

```plantuml
:https request;
:digitalocean loadbalancer
handles TLS termination;
:http request;
switch (nginx running)
case (here)
  :nomad client I;
  stop
case (here)
  :nomad client II;
  stop
case (here)
  :nomad client III;
  stop
```

The architecture relies on a loadbalancer from DigitalOcean to handle the SSL
termination. Going from there, the health check of the loadbalancer is used to
determine on which droplet the nginx job is running - the loadbalancer only
forwards traffic to droplets where the health check is successful. This means 
that even if one droplet would fall away, after a few seconds the health check
should pick up the droplet where the nginx job has been moved to by nomad.

Nginx acts as a reverse proxy - the jobs that need to be accessible from the
outside can be referenced in the `nginx.conf` template section. This mainly
includes Grafana, which in turn relies on Loki, Tempo and Prometheus to be
running (but they don't need to be accessible from the outside).

## Links

- [hashi-up](https://github.com/jsiebens/hashi-up)
- [terraform digitalocean provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)
- [terraform nomad provider](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)
- [observability with consul service mesh](https://www.hashicorp.com/resources/observability-with-hashicorp-consul-connect-service-mesh)
- [adding observability to nomad applications with grafana](https://www.hashicorp.com/resources/adding-observability-to-hashicorp-nomad-applications-with-grafana)
- [plantuml](https://docs.gitlab.com/ee/administration/integration/plantuml.html)
