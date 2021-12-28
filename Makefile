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
	mkdir -p .build/$(GOOS)-$(GOARCH)/
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build
	if [ $(GOOS) = "windows" ] ; then \
		mv ./prometheus_sh_exporter.exe ./.build/$(GOOS)-$(GOARCH)/ ; \
	else \
		mv ./prometheus_sh_exporter ./.build/$(GOOS)-$(GOARCH)/ ; \
	fi ; \

TAG	?=	$(shell git tag | tail -n1)
.PHONY: package
package:
	mkdir -p ./packages/$(TAG)/prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH)
	cp -r prometheus_sh_exporter.service \
		sh.yml \
		commands \
		Makefile \
		LICENSE \
		README.md \
		./packages/$(TAG)/prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH)
	if [ $(GOOS) = "windows" ] ; then \
		cp ./.build/$(GOOS)-$(GOARCH)/prometheus_sh_exporter.exe ./packages/$(TAG)/prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH) ; \
	else \
		cp ./.build/$(GOOS)-$(GOARCH)/prometheus_sh_exporter ./packages/$(TAG)/prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH) ; \
	fi
	cd ./packages/$(TAG) ; \
	if [ $(GOOS) = "windows" ] ; then \
		zip -r prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH).zip ./prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH) ; \
	else \
		tar cvf prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH).tar.gz ./prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH) ; \
	fi ; \
	rm -r ./prometheus_sh_exporter-$(TAG).$(GOOS)-$(GOARCH)

.PHONY: package-all-with-build
package-all-with-build: get
	$(GO) tool dist list | grep 'aix\|darwin\|freebsd\|illumos\|linux\|netbsd\|openbsd\|windows' | grep 'windows' | head -n1 | while read line ; \
	do \
		printf GOOS= > ./.build.env ; \
		echo $$line | cut -f 1 -d "/" >> ./.build.env ; \
		printf GOARCH= >> ./.build.env ; \
		echo $$line | cut -f 2 -d "/" >> ./.build.env ; \
		. ./.build.env ; \
		make build GOOS=$$GOOS GOARCH=$$GOARCH ; \
		make package GOOS=$$GOOS GOARCH=$$GOARCH ; \
	done
	rm ./.build.env

.PHONY: clean
clean:
	-rm -r ./.build ./packages ./.build.env


ETC_DIR						?=/etc/prometheus_sh_exporter
ETC_SH_DIR				?=/etc/prometheus_sh_exporter/sh
SYSTEMD_UNIT_DIR	?=/lib/systemd/system
BIN_DIR						?=/usr/local/bin
EXPOSE_PORT				?=9923
.PHONY: install
install: ./.build/$(GOOS)-$(GOARCH)/prometheus_sh_exporter
	mkdir -p $(ETC_DIR) $(ETC_SH_DIR) $(BIN_DIR) $(SYSTEMD_UNIT_DIR)
	printf 'ETC_DIR=$(ETC_DIR)\nPORT=$(EXPOSE_PORT)' > /etc/default/prometheus_sh_exporter
	cp prometheus_sh_exporter.service $(SYSTEMD_UNIT_DIR)
	systemctl daemon-reload
	cp -n sh.yml $(ETC_DIR) || true
	cp -n ./commands/*.sh $(ETC_SH_DIR) || true
	cp ./.build/$(GOOS)-$(GOARCH)/prometheus_sh_exporter $(BIN_DIR)