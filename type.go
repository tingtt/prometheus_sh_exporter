package main

type Metric struct {
	Name   string
	Label  string
	Shpath string
	Help   string
	Type   string
}

type EtcYaml struct {
	Metrics []Metric
}
