// REFERENCED: http://www.will3942.com/creating-blog-go
// the gists are missing instantiation for the f and post in the else block, add ":" to each

// Package blog is an http server hosting the blog area of pg-h.io.
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"path/filepath"
	"sort"
	"strings"
	"text/template"

	"gopkg.in/russross/blackfriday.v2"
)

// err, create an error variable for the blog scope
var err error
var blogCount = 0

// Post structure
// this should match the posts lines
type Post struct {
	Title   string
	Date    string
	Summary string
	Body    string
	File    string
}

var tmplMetrics = `{{ . }}`

func handler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path[1:] == "" {
		posts := getPosts()
		tmpl := template.New("index.tmpl.html")
		tmpl, err = tmpl.ParseFiles("tmpl/index.tmpl.html")
		if err != nil {
			fmt.Println("ERROR: handler tmpl.ParseFiles", err)
		}
		tmpl.Execute(w, posts)
		blogCount++
	} else if r.URL.Path[1:] == "metrics" {
		metrics := fmt.Sprintf("pghio_blog_hits_count_total %v", blogCount)
		tmpl := template.New("metrics")
		tmpl, err = tmpl.Parse(tmplMetrics)
		if err != nil {
			fmt.Println("ERROR: handler tmpl.Parse", err)
		}
		tmpl.Execute(w, metrics)
	} else if r.URL.Path[1:] == "favicon.ico" {
		http.ServeFile(w, r, "imgs/favicon.ico")
	} else {
		file := "posts/" + r.URL.Path[1:] + ".md"
		fileContents, err := ioutil.ReadFile(file)
		if err != nil {
			fmt.Println("ERROR: handler ioutil.ReadFile", err)
		}
		lines := strings.Split(string(fileContents), "\n")
		title := string(lines[0])
		date := string(lines[1])
		summary := string(lines[2])
		body := strings.Join(lines[3:len(lines)], "\n")
		body = string(blackfriday.Run([]byte(body)))
		post := Post{title, date, summary, body, r.URL.Path[1:]}
		t := template.New("post.tmpl.html")
		t, err = t.ParseFiles("tmpl/post.tmpl.html")
		if err != nil {
			fmt.Println("ERROR: t.ParseFiles", err)
		}
		t.Execute(w, post)
		blogCount++
	}
}

// getPosts creates and returns a slice of Posts from md files under the posts directory.
func getPosts() []Post {
	a := []Post{}
	files, err := filepath.Glob("posts/*.md")
	sort.Sort(sort.Reverse(sort.StringSlice(files)))
	if err != nil {
		fmt.Println("ERROR: getPosts filepath.Glob", err)
	}
	for _, f := range files {
		filename := strings.Replace(f, "posts/", "", -1)
		filename = strings.Replace(filename, ".md", "", -1)
		fileread, err := ioutil.ReadFile(f)
		if err != nil {
			fmt.Println("ERROR: getPosts ioutil.ReadFile", err)
		}
		lines := strings.Split(string(fileread), "\n")
		title := string(lines[0])
		date := string(lines[1])
		summary := string(lines[2])
		body := strings.Join(lines[3:len(lines)], "\n")
		body = string(blackfriday.Run([]byte(body)))
		a = append(a, Post{title, date, summary, body, filename})
	}
	return a
}

func main() {
	fmt.Println("Starting Blog")
	http.HandleFunc("/", handler)
	http.ListenAndServe(":80", nil)
}
