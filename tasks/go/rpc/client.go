package main

import (
	"rpcexample"
	"log"
	"net/rpc"
)

func main() {
	client, err := rpc.DialHTTP("tcp", ":12345")
	if err != nil {
		log.Fatalf("Error in dialing. %s", err)
	}
	args := &rpcexample.Args{
		A: "Stefanos",
	}
	var result rpcexample.Result
	for i := 0; i < 20000; i++ { 	
		err = client.Call("Arith.Multiply", args, &result)
		if err != nil {
			log.Fatalf("error in Arith", err)
		}
	}
	log.Printf("%s  %d\n", args.A, result)
}
