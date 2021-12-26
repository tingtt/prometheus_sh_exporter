all: build

.PHONY: test
test:
	go version

.PHONY: get
get: test
	go mod download

.PHONY: build
build: get
	go build

ETC_DIR=/etc/prometheus/
ETC_SH_DIR=/etc/prometheus/sh/
SYSTEMD_UNIT_DIR=/lib/systemd/system/
BIN_DIR=/usr/local/bin/
.PHONY: install
install: prometheus-linux-shell-exporter
	mkdir -p $(ETC_DIR) $(ETC_SH_DIR) $(BIN_DIR) $(SYSTEMD_UNIT_DIR)
	cp prometheus-linux-shell-exporter.service $(SYSTEMD_UNIT_DIR)
	systemctl daemon-reload
	cp -n linuxsh.yml $(ETC_DIR)
	cp -n ./commands/*.sh $(ETC_SH_DIR)
	cp prometheus-linux-shell-exporter $(BIN_DIR)