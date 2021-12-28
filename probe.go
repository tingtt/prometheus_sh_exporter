package main

import (
	"fmt"

	"github.com/mattn/go-pipeline"
)

func probe(metric Metric) (string, error) {
	out, err := pipeline.Output(
		[]string{"sh", metric.Shpath},
	)
	if err != nil {
		return "", err
	}

	metricStr := ""

	if metric.Help != "" {
		metricStr += fmt.Sprintf("# HELP %s %s\n", metric.Name, metric.Help)
	}

	if metric.Type != "" {
		metricStr += fmt.Sprintf("# TYPE %s %s\n", metric.Name, metric.Type)
	}

	metricStr += fmt.Sprintf("%s{label=\"%s\"} %s", metric.Name, metric.Label, string(out))

	return metricStr, nil
}
