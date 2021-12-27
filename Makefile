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

TAG	?=	$(shell git tag | tail -n1)
.PHONY: package
package: prometheus-linux-shell-exporter
	mkdir -p ./packages/$(TAG)/linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH)
	cp -r prometheus-linux-shell-exporter \
		prometheus-linux-shell-exporter.service \
		linuxsh.yml \
		commands \
		Makefile \
		LICENSE \
		README.md \
		./packages/$(TAG)/linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH)
	if [ $$GOOS == 'windows' ] ; then \
		cp prometheus-linux-shell-exporter.exe ./packages/$(TAG)/linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH) ; \
	fi
	cd ./packages/$(TAG) ; \
	if [ $$GOOS == 'windows' ] ; then \
		zip -r linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH).zip ./linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH) ; \
	else \
		tar cvf linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH).tar.gz ./linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH) ; \
	fi ; \
	rm -r ./linux_shell_expoter-$(TAG).$(GOOS)-$(GOARCH)

.PHONY: package-all-with-build
package-all-with-build: get
	$(GO) tool dist list | grep 'aix\|darwin\|freebsd\|illumos\|linux\|netbsd\|openbsd\|windows' | while read line ; \
	do \
		printf GOOS= > ./.build.env ; \
		echo $$line | cut -f 1 -d "/" >> ./.build.env ; \
		printf GOARCH= >> ./.build.env ; \
		echo $$line | cut -f 2 -d "/" >> ./.build.env ; \
		source ./.build.env ; \
		make build GOOS=$$GOOS GOARCH=$$GOARCH ; \
		make package GOOS=$$GOOS GOARCH=$$GOARCH ; \
	done
	rm ./.build.env


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