package main

import (
	"net/http"
)

func main() {
	hc := &http.Client{
		Transport: &http.Transport{},
	}

	hc.Get("https://google.com") // This will skip TLS verification
}
