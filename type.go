package main

type Label struct {
	Name  string
	Value string
}

type Probe struct {
	Labels []Label
	Shpath string
}

type Metric struct {
	Name   string
	Help   string
	Type   string
	Probes []Probe
}

type EtcYaml struct {
	Metrics []Metric
}
