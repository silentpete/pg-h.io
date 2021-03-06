I converted a simple Prometheus Alertmanager webhook container to run a Go app instead of a Ruby (Sinatra) app.

# Prometheus - Alertmanager Webhook

We use Prometheus to collect metrics. Prometheus can have alerting configured, which is co-managed with Alertmanager. Alertmanager has the ability to send json to a web endpoint ([https://prometheus.io/docs/alerting/configuration/#%3Cwebhook_config%3E](https://prometheus.io/docs/alerting/configuration/#%3Cwebhook_config%3E)). The web endpoint can do stuff based on the information in the json.

## The Sinatra App

Currently we have a couple services running on CentOS hosts that we monitor. We expect those services to be up so their metrics can be collected. If something happens where the service goes down and doesn't come back up automatically, Prometheus will fail to scrape, alertmanager will trigger, and the json will be sent to the web endpoint/webhook (http://\<webhook>:4567/fix-service/).

```ruby
#!/usr/bin/env ruby

require 'sinatra'
require 'rest-client'
require 'logger'

$stdout.sync = true
$stderr.sync = true

set :logging, true
set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  "Hello, from Sinatra! (Prometheus Webhook)"
end

post '/fix-service/' do
  data = JSON.parse(request.body.read)
  num_of_alerts = data["alerts"].count
  (1..num_of_alerts).each do |e|
    alerts_ary = data["alerts"][e - 1]
    instances = alerts_ary["labels"]["instance"]
    host = instances.sub(/:\d+/,'')
    `curl -s -u <username>:<key> -X POST "<jenkins_server>/job/fix_service/buildWithParameters?token=STRING&HOST=#{host}"`
  end
end
```

## The Go App

I converted the Sinatra app for a little project to help me learn more Go. I recreated the app to be swapped out with identical functionality, so nothing really new implemented. The Go binary runs in a "scratch" container, so just swap the version on the container and the new Go app is up and running.

```golang
package main

import (
        "encoding/json"
        "fmt"
        "io/ioutil"
        "log"
        "net/http"
        "regexp"
        "strings"
)

func rootHandler(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "prometheus alertmanager webhook is running!")
        log.Println(r.RemoteAddr, "requested", r.URL)
}

func fixServiceHandler(w http.ResponseWriter, r *http.Request) {
        byt, err := ioutil.ReadAll(r.Body)
        if err != nil {
                log.Panic("error reading Body: ", err)
        }
        defer r.Body.Close()

        if len(byt) == 0 {
                log.Println(r.RemoteAddr, "requested", r.URL, "Body Empty")
                return
        }

        matched, err := regexp.MatchString("alerts", string(byt))
        if err != nil {
                log.Println(r.RemoteAddr, "posted to", r.URL, "error:", err)
                return
        }
        if !matched {
                log.Println("NO alerts found in Body:", string(byt))
                return
        }

        var m interface{}
        err = json.Unmarshal(byt, &m)
        if err != nil {
                log.Panic("error Unmarshalling: ", err)
        }

        alerts := m.(map[string]interface{})["alerts"]
        var hostnames []string // hostnames is equiv to instance/s in prometheus alerts
        for _, alert := range alerts.([]interface{}) {
                labels := alert.(map[string]interface{})["labels"]
                hostnameWithPort := labels.(map[string]interface{})["instance"]
                hostname := strings.Split(hostnameWithPort.(string), ":")[0]
                hostnames = append(hostnames, hostname)
        }

        for _, host := range hostnames {
                log.Println("running fix services on:", host)

                curlAddress := "https://<jenkins_server>/job/fix_service/buildWithParameters?token=STRING&HOST=" + host
                req, err := http.NewRequest("POST", curlAddress, nil)
                if err != nil {
                        log.Panic("error NewRequest: ", err)
                }

                req.SetBasicAuth("<username>", "<key>")

                resp, err := http.DefaultClient.Do(req)
                if err != nil {
                        log.Panic("error HTTP Client.Do: ", err)
                }
                defer resp.Body.Close()
        }
}

func main() {
        log.Println("Starting Promethues Alertmanager Webhook")
        http.HandleFunc("/", rootHandler)
        http.HandleFunc("/fix-service/", fixServiceHandler)
        log.Fatal(http.ListenAndServe(":4567", nil))
}
```

## Dockerfile

A two stage dockerfile is used to compile the binary in one build step, then copy it into its own container in the second step. This keeps the size to a minimum.

> Note: during docker run, I do map in certs for communication.

```none
### Stage One
FROM golang:1.10-alpine as binaryBuilder

WORKDIR /go/src/app

COPY webhook/. .

RUN go build -tags netgo -a -v -o ./webhook

### Stage Two
FROM scratch

WORKDIR /opt/prometheus

COPY --from=binaryBuilder /go/src/app/webhook .

EXPOSE 4567

CMD ["/opt/prometheus/webhook"]
```

## Docker Imgages

### Go

```none
<domain>/webhook    latest     <ID>     2 days ago       7.11MB
```

### Ruby

```none
<domain>/webhook    5          <ID>     3 months ago     206MB
```

## Docker Stats

### Go

```none
CONTAINER ID     NAME        CPU %     MEM USAGE     MEM %     PIDS
<ID>             webhook     0.00%     2.098MiB      0.01%     4
```

### Ruby

```none
CONTAINER ID     NAME        CPU %     MEM USAGE     MEM %     PIDS
<ID>             webhook     0.01%     2.195MiB      0.01%     23
```

## Conclusion

The process of changing from Ruby to Go was fairly easy for this application. It did help me understand working with Go better as well. Finding documentation online to help with any questions was a Google or GoDocs click away. The container resource benefit was small, but it is worth noting.

## References

- [https://blog.golang.org/json-and-go](https://blog.golang.org/json-and-go)
- [https://gobyexample.com/json](https://gobyexample.com/json)
- [https://mholt.github.io/json-to-go/](https://mholt.github.io/json-to-go/)
