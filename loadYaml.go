package main

import (
	"io/ioutil"

	"github.com/go-yaml/yaml"
)

func loadYamlFile(path string) ([]byte, error) {
	buf, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}

	return buf, nil
}

func yamlDataToStructArray(fileBuffer []byte) ([]Metric, error) {
	var data EtcYaml

	err := yaml.Unmarshal(fileBuffer, &data)
	if err != nil {
		return nil, err
	}

	return data.Metrics, nil
}
