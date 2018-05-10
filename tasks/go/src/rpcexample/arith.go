package rpcexample

import (
	"log"
)

//Holds arguments to be passed to service Arith in RPC call
type Args struct {
	A string
}

//Representss service Arith with method Multiply
type Arith string

//Result of RPC call is of this type
type Result string

//This procedure is invoked by rpc and calls rpcexample.Multiply which stores product of args.A and args.B in result pointer
func (t *Arith) Multiply(args Args, result *Result) error {
	return Multiply(args, result)
}

//stores product of args.A and args.B in result pointer
func Multiply(args Args, result *Result) error {
	log.Printf("Hello World %d \n", args.A)
	
	//t := strconv.Itoa(args.A * args.B)
	*result = Result("Hello World!")
	return nil
}
