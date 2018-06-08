# Create the 'blog' Go binary in a alpine Go environment for eash of transfering into a small container
FROM golang:1.10-alpine as binaryBuilder

# Need git for 'go get'
RUN \
  apk update \
  && apk add git

# get the markdown parser
RUN go get -v gopkg.in/russross/blackfriday.v2

COPY $PWD /go/src/blog

RUN cd /go/src/blog && go build -v blog.go


# Create a alpine container and copy the binary built from above into and alpine container to run the binary
FROM alpine:3.7

# TODO: probably should just mount in the files, at least the posts... that way don't need to rebuild the container to get the new blog post
COPY $PWD/index.tmpl.html $PWD/post.tmpl.html /opt/blog/
COPY --from=binaryBuilder /go/src/blog/blog /opt/blog/blog

# expose the port the container will run on... may want to fix this to take in a ENV var
EXPOSE 80

# Have to start from the workdir so the blog can see the files in the directory, or we'll need to figure that out so it doesn't matter.
WORKDIR /opt/blog/

CMD ["./blog"]
