package main

import (
	"crypto/tls"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"golang.org/x/net/http2"
)

func main() {
	hc := &http.Client{
		Transport: &http2.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}
	for i := 0; i < 20000; i++ {

	resp, err := hc.Get("https://100.69.12.250:3000")
	if err != nil {
		log.Fatal(err)
	}

	body, _ := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	fmt.Printf("%s", body)
	}
}
