# Create the 'pghio' Go binary in a alpine Go environment for eash of transfering into a small container
FROM golang:1.10-alpine as binaryBuilder

# Need git for 'go get'
RUN \
  apk update \
  && apk add git

# get the markdown parser
# RUN go get -v github.com/russross/blackfriday

COPY $PWD /go/src/pghio

RUN cd /go/src/pghio && go build -v pghio.go


# Create a alpine container and copy the binary built from above into and alpine container to run the binary
FROM alpine:3.7

# TODO: probably should just mount in the files, at least the posts... that way don't need to rebuild the container to get the new blog post
# COPY $PWD/ /opt/pghio
COPY --from=binaryBuilder /go/src/pghio/pghio /opt/pghio/pghio

# expose the port the container will run on... may want to fix this to take in a ENV var
EXPOSE 80

# Have to start from the workdir so the site can see the files in the directory, or we'll need to figure that out so it doesn't matter.
WORKDIR /opt/pghio/

CMD ["./pghio"]
