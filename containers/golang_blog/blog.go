// REFERENCED: http://www.will3942.com/creating-blog-go
// the gists are missing instantiation for the f and post in the else block, add ":" to each
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"path/filepath"
	"strings"
	"text/template"

	"github.com/russross/blackfriday"
)

// Post structure
// this should match the posts lines
type Post struct {
	Title   string
	Date    string
	Summary string
	Body    string
	File    string
}

func handler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path[1:] == "" {
		posts := getPosts()
		t := template.New("index.tmpl.html")
		t, err := t.ParseFiles("index.tmpl.html")
		if err != nil {
			fmt.Println("ERROR:", err)
		}
		t.Execute(w, posts)
	} else {
		f := "posts/" + r.URL.Path[1:] + ".md"
		fileread, err := ioutil.ReadFile(f)
		if err != nil {
			fmt.Println("ERROR:", err)
		}
		lines := strings.Split(string(fileread), "\n")
		title := string(lines[0])
		date := string(lines[1])
		summary := string(lines[2])
		body := strings.Join(lines[3:len(lines)], "\n")
		body = string(blackfriday.MarkdownCommon([]byte(body)))
		post := Post{title, date, summary, body, r.URL.Path[1:]}
		t := template.New("post.tmpl.html")
		t, err = t.ParseFiles("post.tmpl.html")
		if err != nil {
			fmt.Println("ERROR:", err)
		}
		t.Execute(w, post)
	}
}

func getPosts() []Post {
	a := []Post{}
	files, err := filepath.Glob("posts/*.md")
	if err != nil {
		fmt.Println("ERROR:", err)
	}
	for _, f := range files {
		file := strings.Replace(f, "posts/", "", -1)
		file = strings.Replace(file, ".md", "", -1)
		fileread, _ := ioutil.ReadFile(f)
		lines := strings.Split(string(fileread), "\n")
		title := string(lines[0])
		date := string(lines[1])
		summary := string(lines[2])
		body := strings.Join(lines[3:len(lines)], "\n")
		body = string(blackfriday.MarkdownCommon([]byte(body)))
		a = append(a, Post{title, date, summary, body, file})
	}
	return a
}

func main() {
	fmt.Println("Starting Blog")
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8000", nil)
}
