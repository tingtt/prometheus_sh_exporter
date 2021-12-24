package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
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
