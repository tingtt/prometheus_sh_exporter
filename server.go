package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

func handler(w http.ResponseWriter, r *http.Request) {

	data, err := loadYamlFile(os.Getenv("YAML_PATH"))
	if err != nil {
		fmt.Printf("%v\n", err)
		os.Exit(1)
		return
	}

	metrics, err := yamlDataToStructArray(data)
	if err != nil {
		fmt.Printf("%v\n", err)
		os.Exit(1)
		return
	}

	for _, metric := range metrics {
		metricStr, err := probe(metric)
		if err != nil {
			fmt.Printf("%v\n", err)
			os.Exit(1)
			return
		}
		fmt.Fprint(w, metricStr)
	}
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
