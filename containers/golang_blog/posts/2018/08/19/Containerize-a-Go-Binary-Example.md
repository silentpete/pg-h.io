A basic overview of how to build a Go binary and run it in a Docker container. Three different examples included to demonstrate how it could be done: FROM golang, FROM alpine, FROM scratch.

# Go (Hello World!) in a Docker Container

After we have a working HTTP Go code example, how can we run it in a docker container?

## Go Code Example

This simple HTTP Hello World! example can be run with `go run main.go` and should be browsable at `http://localhost:6060/`

main.go:

```none
package main

import (
        "fmt"
        "log"
        "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "<h1>Hello World!</h1>")
        log.Println()
}

func main() {
        http.HandleFunc("/", handler)
        err := http.ListenAndServe("0.0.0.0:6060", nil)
        if err != nil {
                log.Println(err)
        }
}
```

## Example 1: In a 'golang' Container

We can use a official golang image to start from. This image comes with Go in the container, all we have to do is copy in our source.

[https://hub.docker.com/_/golang/](https://hub.docker.com/_/golang/)

Dockerfile:

```none
# Start from a golang image
FROM golang

# set working directory, this is the path you are inserted into in the container
WORKDIR /go/src/helloworld

# copy in the source file from the current directory
COPY $PWD/main.go .

# compile the binary for linux
RUN GOOS=linux GOARCH=386 go build -v main.go

# expose the port the container will run on. This should match the port in the binary
EXPOSE 6060

# command to run when the container is started
CMD ["./main"]
```

## Example 2: In a 'alpine' Container

The Alpine environment is a very minimal OS. This removes bloat that the Go binary does not need to run. The running container will retain a shell environment.

[https://hub.docker.com/_/alpine/](https://hub.docker.com/_/alpine/)

Also, we will use multistage builds in this dockerfile.

[https://docs.docker.com/develop/develop-images/multistage-build/](https://docs.docker.com/develop/develop-images/multistage-build/)

Dockerfile:

```none
FROM golang as binaryBuilder
WORKDIR /go/src/helloworld
COPY $PWD/main.go .
RUN GOOS=linux GOARCH=386 go build -v main.go

# using a Multi Stage build
# start next container from an alpine image
FROM alpine

# copy the binary built in the golang container into the alpine container. this allows us to drop the golang container size tremendously
COPY --from=binaryBuilder /go/src/helloworld/main /opt/helloworld/

WORKDIR /opt/helloworld/
EXPOSE 6060
CMD ["./main"]
```

## Example 3: In a 'scratch' Container

We can use a multistage build with the final stage being a _scratch_ image. This is a minimal image. Since Go compiles with all the source it needs to run, we do not need an environment in the running container.

[https://docs.docker.com/develop/develop-images/baseimages/](https://docs.docker.com/develop/develop-images/baseimages/)

[https://hub.docker.com/_/scratch/](https://hub.docker.com/_/scratch/)

Dockerfile:

```none
FROM golang as buildBinary
WORKDIR /go/src/helloworld
COPY "$PWD"/main.go .
RUN GOOS=linux GOARCH=386 go build -v -o main main.go

# scratch containers are empty
FROM scratch

COPY --from=buildBinary /go/src/helloworld/main .
EXPOSE 6060
CMD ["./main"]
```

## Docker Build

The following docker build command can be used with each example above.

```none
docker build -t helloworld .
```

## Docker Run

The following docker run command can be used with each example above.

```none
docker run -d --name=helloworld --log-driver=json-file -p <host port ie. 6060>:6060 helloworld:latest
```

## Check Localhost

After starting the container, it should be up and running on whatever port you mapped in. You can look at the container in docker now.

Should see the helloworld container running.

```none
docker ps
```

Should be no logs with the basic main.go file we provided.

```none
docker logs helloworld
```

Curl the container to look at the response

```none
curl -L http://localhost:6060
```

## Conclusion

How Go compiles into a runable binary is awesome. Putting the binary into a docker container is fairly easy (at least in this example), and it creates small containers that run optimally.

There is a give and take whether to run the binary in a container with or without a OS level entrypoint. Having the ability to get into the container can help with potential troubleshooting. I feel that once the container is done being developed, it probably should be put into a scratch image.
