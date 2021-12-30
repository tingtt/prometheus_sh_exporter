package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
)

var (
	port        = flag.Int("port", 9923, "Server port")
	cfgFilePath = flag.String("config.file", "/etc/prometheus_sh_exporter/sh.yml", "The path to configuration file.")
)

func root(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, rootPage())
}

func metrics(w http.ResponseWriter, r *http.Request) {

	data, err := loadYamlFile(*cfgFilePath)
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
	flag.Parse()

	http.HandleFunc("/", root)
	http.HandleFunc("/metrics", metrics)
	fmt.Printf("Server started on http://localhost:%d\n", *port)
	http.ListenAndServe(fmt.Sprintf(":%d", *port), nil)
}
