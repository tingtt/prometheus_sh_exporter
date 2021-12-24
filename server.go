package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"github.com/mattn/go-pipeline"
)

func handler(w http.ResponseWriter, r *http.Request) {
	out, err := pipeline.Output(
		[]string{"ls", "-t", os.Getenv("LS_PATH")},
		[]string{"head", "-n1"},
		[]string{"cut", "-f", "1", "-d", "_"},
	)

	if err != nil {
		fmt.Fprintln(w, err.Error())
		return
	}

	fmt.Fprintln(w, string(out))
}

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		fmt.Printf("%v\n", err)
	}

	port := "9923"
	if err == nil {
		port = os.Getenv("PORT")
	}

	http.HandleFunc("/", handler)
	fmt.Printf("Server started on http://localhost:%s\n", port)
	http.ListenAndServe(":"+port, nil)
}
