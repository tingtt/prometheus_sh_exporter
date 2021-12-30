package main

import (
	"fmt"

	"github.com/mattn/go-pipeline"
)

func probe(metric Metric) (string, error) {
	metricStr := ""

	if metric.Help != "" {
		metricStr += fmt.Sprintf("# HELP %s %s\n", metric.Name, metric.Help)
	}

	if metric.Type != "" {
		metricStr += fmt.Sprintf("# TYPE %s %s\n", metric.Name, metric.Type)
	}

	for _, probe := range metric.Probes {
		out, err := pipeline.Output(
			[]string{"sh", probe.Shpath},
		)
		if err != nil {
			return "", err
		}

		metricStr += metric.Name + "{"

		for _, label := range probe.Labels {
			metricStr += fmt.Sprintf("%s=\"%s\",", label.Name, label.Value)
		}
		metricStr = metricStr[:len(metricStr)-1]

		metricStr += fmt.Sprintf("} %s", string(out))
	}

	return metricStr, nil
}
