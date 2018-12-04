package main

import (
	"rpcexample"
	"log"
	"net"
	"net/http"
	"net/rpc"
)

func main() {
	arith := new(rpcexample.Arith)
	err := rpc.Register(arith)
	if err != nil {
		log.Fatalf("Format of service Arith isn't correct. %s", err)
	}
	rpc.HandleHTTP()
	l, e := net.Listen("tcp", "195.251.251.27:12345")
	if e != nil {
		log.Fatalf("Couldn't start listening on port 1234. Error %s", e)
	}
	log.Println("Serving RPC handler")
	err = http.Serve(l, nil)
	if err != nil {
		log.Fatalf("Error serving: %s", err)
	}
}
