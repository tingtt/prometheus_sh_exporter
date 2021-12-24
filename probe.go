package main

import (
	"fmt"
	"os"

	"github.com/mattn/go-pipeline"
)

func probe(metric Metric) (string, error) {
	command_dir_path := os.Getenv("COMMAND_DIR_PATH")
	if command_dir_path[1:] != "/" {
		command_dir_path += "/"
	}
	out, err := pipeline.Output(
		[]string{"sh", command_dir_path + metric.Shfilename},
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

	metricStr += fmt.Sprintf("%s{label=%s} %s", metric.Name, metric.Label, string(out))

	return metricStr, nil
}
