package main

import (
	"io"
	"log"
	"net/http"
	"os"
)

func main() {
	hc := &http.Client{
		Transport: &http.Transport{},
	}

	resp, err := hc.Get("https://google.com") // This will skip TLS verification
	if err != nil {
		log.Fatalf("Failed to make request: %v", err)
	}
	defer resp.Body.Close() //nolint:errcheck

	io.Copy(os.Stdout, resp.Body) //nolint:errcheck
}
