FROM golang:1.10

RUN go get github.com/prometheus/node_exporter

RUN go build -o /tmp/prometheus_node_exporter -a -v ${GOPATH}/src/github.com/prometheus/node_exporter/node_exporter.go

