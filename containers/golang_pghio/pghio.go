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
	http.HandleFunc("/", pghio)
	http.HandleFunc("/metrics", metrics)
	http.ListenAndServe(":80", nil)
}

func pghio(w http.ResponseWriter, r *http.Request) {
	tmpl := template.New("index.html")
	tmpl, err = tmpl.ParseFiles("index.html")
	if err != nil {
		fmt.Println("ERROR:", err)
	}
	tmpl.Execute(w, "")
	pghioHitCount++
}

func metrics(w http.ResponseWriter, r *http.Request) {
	m := fmt.Sprintf("pghio_hit_count_total %v", pghioHitCount)
	fmt.Fprintf(w, m)
}
