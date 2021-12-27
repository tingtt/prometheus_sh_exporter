GO			?= go
GOOS		?= $(shell $(GO) env GOOS)
GOARCH	?= $(shell $(GO) env GOARCH)

all: build

.PHONY: test
test:
	go version

.PHONY: get
get: test
	go mod download

.PHONY: build
build: get
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build

ETC_DIR						?=/etc/prometheus-linux-shell-exporter
ETC_SH_DIR				?=/etc/prometheus-linux-shell-exporter/sh
SYSTEMD_UNIT_DIR	?=/lib/systemd/system
BIN_DIR						?=/usr/local/bin
EXPOSE_PORT				?=9923
.PHONY: install
install: prometheus-linux-shell-exporter
	mkdir -p $(ETC_DIR) $(ETC_SH_DIR) $(BIN_DIR) $(SYSTEMD_UNIT_DIR)
	echo -e ETC_DIR=$(ETC_DIR)\nPORT=$(EXPOSE_PORT) > /etc/default/prometheus-linux-shell-exporter
	cp prometheus-linux-shell-exporter.service $(SYSTEMD_UNIT_DIR)
	systemctl daemon-reload
	cp -n linuxsh.yml $(ETC_DIR) || true
	cp -n ./commands/*.sh $(ETC_SH_DIR) || true
	cp prometheus-linux-shell-exporter $(BIN_DIR)