FROM golang:1.13

# RUN go get -v github.com/google/cadvisor
RUN \
  mkdir -p ${GOPATH}/src/github.com/google
RUN \
  cd ${GOPATH}/src/github.com/google/ \
  && git clone --depth 1 http://github.com/google/cadvisor.git -b release-v0.32

RUN \
  cd ${GOPATH}/src/github.com/google/cadvisor/ \
  && make

RUN \
  cp ${GOPATH}/src/github.com/google/cadvisor/cadvisor /tmp/cadvisor

# RUN go build -o /tmp/cadvisor -a -v ${GOPATH}/src/github.com/google/cadvisor/cadvisor.go
