### Prometheus.io Remote Storage Adapter Binary gets built here
FROM golang:1.10-alpine as binaryBuilder

RUN apk --no-cache --update add git

ENV prometheusTag="v2.2.1"
ENV prometheusGitRepo="https://github.com/prometheus/prometheus.git"

WORKDIR /usr/local/go/src/vendor/github.com/prometheus/

RUN \
  git clone ${prometheusGitRepo} \
  && cd ./prometheus/ \
  && git checkout tags/${prometheusTag} \
  && cd ./documentation/examples/remote_storage/remote_storage_adapter/ \
  && go build -tags netgo -a -v -o ./remote_storage_adapter

### Prometheus.io Remote Storage Adapter Container gets built here
FROM alpine:3.7

WORKDIR /opt/

COPY --from=binaryBuilder /usr/local/go/src/vendor/github.com/prometheus/prometheus/documentation/examples/remote_storage/remote_storage_adapter/remote_storage_adapter /opt/remote_storage_adapter

RUN \
  apk add --no-cache --update curl \
  && rm -rf /var/cache/apk/* \
  && chmod 0750 *

COPY setup.sh /opt/setup.sh

EXPOSE 9201

CMD ["/bin/sh","/opt/setup.sh"]
