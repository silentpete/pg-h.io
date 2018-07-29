// REFERENCED: http://www.will3942.com/creating-blog-go
// the gists are missing instantiation for the f and post in the else block, add ":" to each

// Package blog is an http server hosting the blog area of pg-h.io.
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
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
	Address string
}

var tmplMetrics = `{{ . }}`

func main() {
	fmt.Println("Starting Blog")
	http.HandleFunc("/", handler)
	http.ListenAndServe(":80", nil)
}

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
		fmt.Fprintf(w, "pghio_blog_hits_count_total %v\n", blogCount)
	} else if r.URL.Path[1:] == "favicon.ico" {
		http.ServeFile(w, r, "imgs/favicon.ico")
	} else {
		posts := getPosts()

		var requestedPost int
		for i, p := range posts {
			a := p.Address
			_, b := filepath.Split(strings.ToLower(r.URL.Path[1:]))
			if a == b {
				requestedPost = i
			}
		}

		t := template.New("post.tmpl.html")
		t, err = t.ParseFiles("tmpl/post.tmpl.html")
		if err != nil {
			fmt.Println("ERROR: t.ParseFiles", err)
		}

		t.Execute(w, posts[requestedPost])
		blogCount++
	}
}

// getPosts creates and returns a slice of Posts from md files under the posts directory.
func getPosts() []Post {
	a := []Post{}
	files := getPathsWMarkdownFiles("posts")
	// fmt.Println(files)
	for _, fullpath := range files {

		// get the post name
		filename := filenameFromPath(fullpath)
		// fmt.Println("DEV filename:", filename)

		// get the title
		title := titleFromFullpath(fullpath)
		// fmt.Println("DEV title:", title)

		// get the pretty date
		date := prettyDateFromPath(fullpath)
		// fmt.Println("DEV date:", date)

		// get the summary
		summary := summaryFromFile(fullpath)
		// fmt.Println("DEV summary:", summary)

		// get the body
		body := bodyFromFile(fullpath)
		// fmt.Println("DEV body:", body)

		a = append(a, Post{title, date, summary, body, fullpath, filename})
	}
	return a
}

// getPathsWMarkdownFiles takes a path and will return all full paths with .md files in string slice.
func getPathsWMarkdownFiles(path string) []string {
	// recursively get paths from 'path'
	var paths []string
	err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
		paths = append(paths, path)
		return nil
	})
	if err != nil {
		fmt.Printf("error walking the path %q: %v\n", path, err)
	}

	// from 'paths', get paths with .md in them, discard all others
	var files []string
	for _, p := range paths {
		_, file := filepath.Split(p)
		if strings.Contains(file, ".md") {
			// now I have the paths with .md
			files = append(files, p)
		}
	}

	// return the full paths with filesname ending in md
	return files
}

func filenameFromPath(fullpath string) string {
	_, filename := filepath.Split(fullpath)
	filename = strings.ToLower(strings.Replace(filename, ".md", "", -1))
	filename = strings.ToLower(strings.Replace(filename, "---", "-", -1))
	filename = strings.ToLower(strings.Replace(filename, "--", "-", -1))
	filename = strings.ToLower(strings.Replace(filename, "(", "", -1))
	filename = strings.ToLower(strings.Replace(filename, ")", "", -1))
	return filename
}

func titleFromFullpath(fullpath string) string {
	_, filename := filepath.Split(fullpath)
	filename = strings.Replace(filename, ".md", "", -1)
	filename = strings.Replace(filename, "---", "++", -1)
	filename = strings.Replace(filename, "--", "+", -1)
	filename = strings.Replace(filename, "-", " ", -1)
	filename = strings.Replace(filename, "++", " - ", -1)
	filename = strings.Replace(filename, "+", "-", -1)
	return filename
}

func prettyDateFromPath(pathWFile string) string {
	dir, _ := filepath.Split(pathWFile)
	splitDir := strings.Split(dir, "\\")

	// drop the first element which is posts
	splitDir = append(splitDir[:0], splitDir[1:]...)

	// set date variables
	year := splitDir[0]
	month := splitDir[1]
	day := splitDir[2]

	day = strings.TrimPrefix(day, "0")

	switch month {
	case "01":
		month = "January"
	case "02":
		month = "February"
	case "03":
		month = "March"
	case "04":
		month = "April"
	case "05":
		month = "May"
	case "06":
		month = "Jume"
	case "07":
		month = "July"
	case "08":
		month = "August"
	case "09":
		month = "September"
	case "10":
		month = "October"
	case "11":
		month = "November"
	case "12":
		month = "December"
	default:
		log.Println("received month \"", month, "\"")
	}

	return month + " " + day + ", " + year
}

func summaryFromFile(f string) string {
	fileread, err := ioutil.ReadFile(f)
	if err != nil {
		log.Println("ERROR: summary ioutil.ReadFile", err)
	}
	lines := strings.Split(string(fileread), "\n")
	return string(lines[0])
}

func bodyFromFile(f string) string {
	fileread, err := ioutil.ReadFile(f)
	if err != nil {
		fmt.Println("ERROR: body ioutil.ReadFile", err)
	}
	lines := strings.Split(string(fileread), "\n")
	body := strings.Join(lines[2:len(lines)], "\n")
	return string(blackfriday.Run([]byte(body)))
}
