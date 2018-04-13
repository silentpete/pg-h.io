FROM golang:1.10

# RUN go get -v github.com/google/cadvisor
RUN \
  echo "INFO: mkdir" \
  && mkdir -p ${GOPATH}/src/github.com/google
RUN \
  echo "INFO: git clone" \
  && cd ${GOPATH}/src/github.com/google/ \
  && git clone --depth 1 http://github.com/google/cadvisor.git -b release-v0.29

RUN \
  echo "INFO: make" \
  && cd ${GOPATH}/src/github.com/google/cadvisor/ \
  && make

RUN \
  echo "INFO: copy cadvisor" \
  && cp ${GOPATH}/src/github.com/google/cadvisor/cadvisor /tmp/cadvisor

# RUN go build -o /tmp/cadvisor -a -v ${GOPATH}/src/github.com/google/cadvisor/cadvisor.go
