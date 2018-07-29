# Create the Go binary
FROM golang as binaryBuilder
# get the markdown parser
RUN go get -v gopkg.in/russross/blackfriday.v2
WORKDIR /go/src/app
COPY $PWD/blog.go .
RUN env GOOS=linux GOARCH=386 go build -v -o blog blog.go

# Create a alpine container and copy the binary built from above into and alpine container to run the binary
FROM scratch
WORKDIR /opt/blog/
# Copy in binary
COPY --from=binaryBuilder /go/src/app/blog blog
# expose the port the container will run on... may want to fix this to take in a ENV var
EXPOSE 80
CMD ["./blog"]
