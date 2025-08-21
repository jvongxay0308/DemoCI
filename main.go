package main

import (
	"crypto/tls"
	"net/http"
)

func main() {
	hc := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}

	hc.Get("https://google.com") // This will skip TLS verification
}
