FROM alpine:3.15.0

# see https://pkgs.alpinelinux.org/packages
ENV CURL_VERSION "7.80.0-r0"

ENV ANSIBLE_VERSION "4.8.0-r0"
ENV GO_VERSION "1.17.4-r0"
ENV TRIVY_VERSION "0.23.0"
ENV TERRAFORM_VERSION "1.1.5"
ENV PACKER_VERSION "1.7.10"

WORKDIR /workspace

RUN apk add --no-cache \
  curl=${CURL_VERSION} \
  go=${GO_VERSION} \
  ansible=${ANSIBLE_VERSION} \
  && curl -o trivy.tar.gz -sSL https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz \
  && tar -C /usr/local/bin -xzf trivy.tar.gz \
  && mkdir -p /var/cache/trivy \
  && trivy --cache-dir /var/cache/trivy image --download-db-only \
  && curl -o terraform.tar.gz -sSL https://github.com/hashicorp/terraform/archive/refs/tags/v${TERRAFORM_VERSION}.tar.gz \
  && tar -C /usr/local/bin -xzf terraform.tar.gz \
  && curl -o packer.tar.gz -sSL https://github.com/hashicorp/packer/archive/refs/tags/v${PACKER_VERSION}.tar.gz \
  && tar -C /usr/local/bin -xzf packer.tar.gz

