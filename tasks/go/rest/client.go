package main

import (
    "net/http"
    "fmt"
    "log"
    "io/ioutil"
)

func main() {

    url := "http://localhost:3000"
    req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		log.Fatal(err)
	}

    client := &http.Client{}

for i := 0; i < 4500; i++ {

    resp, err := client.Do(req)
    if err != nil {
        panic(err)
    }

    //fmt.Printf("STATUS: ",resp.Status)
    body, _ := ioutil.ReadAll(resp.Body)
    fmt.Println("response Body:", string(body))
}
}
