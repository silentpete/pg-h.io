package main

import (
	"fmt"
	"html/template"
	"net/http"
)

var err error
var pghioHitCount = 0

func main() {
	fmt.Println("Starting pg-h.io")
	http.HandleFunc("/favicon.ico", favicon)
	http.HandleFunc("/", pghio)
	http.HandleFunc("/metrics", metrics)
	http.ListenAndServe(":80", nil)
}

func pghio(w http.ResponseWriter, r *http.Request) {
	tmpl := template.New("index.html")
	tmpl, err = tmpl.ParseFiles("html/index.html")
	if err != nil {
		fmt.Println("ERROR: pghio tmpl.ParseFiles", err)
	}
	tmpl.Execute(w, "")
	pghioHitCount++
}

func metrics(w http.ResponseWriter, r *http.Request) {
	m := fmt.Sprintf("pghio_hit_count_total %v", pghioHitCount)
	fmt.Fprintf(w, m)
}

func favicon(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "imgs/favicon.ico")
}
