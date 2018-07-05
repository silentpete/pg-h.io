package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
)

var pghioHitCount = 0

func main() {
	log.Println("Starting pg-h.io")
	http.HandleFunc("/favicon.ico", favicon)
	http.HandleFunc("/", pghio)
	http.HandleFunc("/metrics", metrics)
	http.ListenAndServe(":80", nil)
}

func pghio(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		tmpl := template.New("index.html")
		tmpl, err := tmpl.ParseFiles("html/index.html")
		if err != nil {
			log.Println("ERROR: pghio tmpl.ParseFiles", err)
		}
		tmpl.Execute(w, "")
		pghioHitCount++
		log.Println(r.RemoteAddr, "requested", r.RequestURI)
	}
	if r.Method == "POST" {
		r.ParseForm() // need to parse the form before interacting with form data
		text := r.Form["text"]
		switch text[0] {
		case "pg --blog":
			http.Redirect(w, r, "http://blog.pg-h.io/", http.StatusFound)
		case "pg --blog-metrics":
			http.Redirect(w, r, "http://blog.pg-h.io/metrics", http.StatusFound)
		case "pg --github":
			http.Redirect(w, r, "https://github.com/silentpete", http.StatusFound)
		case "pg --grafana":
			http.Redirect(w, r, "http://grafana.pg-h.io/", http.StatusFound)
		case "pg --grafana-metrics":
			http.Redirect(w, r, "http://grafana.pg-h.io/metrics", http.StatusFound)
		case "pg --help":
			http.Redirect(w, r, "/", http.StatusFound)
		case "pg -h":
			http.Redirect(w, r, "/", http.StatusFound)
		case "pg --prometheus":
			http.Redirect(w, r, "http://prometheus.pg-h.io/", http.StatusFound)
		case "pg --prometheus-metrics":
			http.Redirect(w, r, "http://prometheus.pg-h.io/metrics", http.StatusFound)
		case "pg --resume":
			http.Redirect(w, r, "https://www.linkedin.com/in/petegallerani/", http.StatusFound)
		default:
			http.Redirect(w, r, "/", http.StatusFound)
		}
	}
}

func metrics(w http.ResponseWriter, r *http.Request) {
	m := fmt.Sprintf("pghio_hit_count_total %v", pghioHitCount)
	fmt.Fprintf(w, m)
}

func favicon(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "imgs/favicon.ico")
}
