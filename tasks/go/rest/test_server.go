package main

import (
	"net/http"
	//"fmt"
	"time"
	"golang.org/x/net/http2"
)

func main() {
	var s http.Server
	http2.VerboseLogs = true
	s.Addr = ":3000"

	http2.ConfigureServer(&s, nil)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		//w.Header().Set("Content-Type", "text/plain")
		//fmt.Fprintf(w, "Hello World")
		w.Write([]byte("Hello world."))
		time.Sleep(2 * time.Second)
	})
	http.ListenAndServe(":3000", nil)

	//log.Fatal(s.ListenAndServeTLS("server.crt", "server.key"))
}
