package main

type Metric struct {
	Name       string
	Label      string
	Shfilename string
	Help       string
	Type       string
}

type EtcYaml struct {
	Metrics []Metric
}
