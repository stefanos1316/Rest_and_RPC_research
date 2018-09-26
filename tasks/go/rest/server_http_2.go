package main

import (
	"golang.org/x/net/http2"
	"net/http"
)

func response(rw http.ResponseWriter, request *http.Request) {
    rw.Write([]byte("Hello world."))
}

func main() {
    http.HandleFunc("/", response)
    var srv http.Server
    srv.Addr = ":3000"

    //Enable http2

    http2.ConfigureServer(&srv, nil)
    http.ListenAndServe(":3000", nil)
}
