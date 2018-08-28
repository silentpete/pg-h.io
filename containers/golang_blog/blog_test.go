package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestBlogHandler(t *testing.T) {
	// NewRequest returns a new Request given a method, URL, and optional body.
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}
	// fmt.Println("the request\n#####\n", req, "\n#####\n")

	// NewRecorder returns an initialized ResponseRecorder. This is an empty pointer at the moment.
	rr := httptest.NewRecorder()
	// fmt.Println("new response recorder\n#####\n", rr, "\n#####\n")

	// the handler is from blog.go
	blogHandler := http.HandlerFunc(blog)
	// fmt.Println("the blog handler\n#####\n", blogHandler, "\n#####\n")

	// Server up the HTTP, this will call the request and write the response to the recorder.
	blogHandler.ServeHTTP(rr, req)
	// fmt.Println("the response recorder code\n#####\n", rr.Code, "\n#####\n")
	// fmt.Println("the response recorder body\n#####\n", rr.Body, "\n#####\n")

	// Check the status code is what we expect.
	got := rr.Code
	if got != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			got, http.StatusOK)
	}

	// fmt.Println("the request\n#####\n", req, "\n#####\n")
}
