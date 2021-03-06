# Sh Exporter

The shell exporter allows probing with shell scripts.

## Get started

Download the most suitable binary from [the releases tab](https://github.com/tingtt/prometheus_sh_exporter/releases).

### Run from binaries

```bash
./prometheus_sh_exporter -port 9923 -config.file sh.yml
```

### Run as systemd service

```bash
make install \
  BIN_DIR=/usr/local/bin \
  ETC_DIR=/etc/prometheus_sh_exporter \
  ETC_SH_DIR=/etc/prometheus_sh_exporter/sh \
  SYSTEMD_UNIT_DIR=/lib/systemd/system \
  EXPOSE_PORT=9923

systemctl enable --now prometheus_sh_exporter.service
```

## Configuration

Example config:

```yaml
metrics:
  - name: last_backup_time # Metric name
    help: "Unix time of last gitlab backup was made." # Metric help message
    type: gauge # Metric type
    probes:
      # last_backup_time{target="gitlab"}
      - shpath: "/etc/prometheus_sh_exporter/sh/sample_last_gitlab_backup_time.sh" # Absolute path to shell script file
        labels: # Metric labels
          - name: "target"
            value: "gitlab"

      # last_backup_time{target="gitlab-etc"}
      - shpath: "/etc/prometheus_sh_exporter/sh/sample_last_gitlabetc_backup_time.sh"
        labels:
          - name: "target"
            value: "gitlab-etc"
```

```bash
systemctl restart prometheus_sh_exporter.service

curl localhost:9923/metrics

# HELP last_backup_time Unix time of last gitlab backup was made.
# TYPE last_backup_time gauge
last_backup_time{label="gitlab"} ...
last_backup_time{label="gitlab-etc"} ...
```

```yaml:prometheus.yml
scrape_configs:
  - job_name: sh
    static_configs:
      - targets:
          - 127.0.0.1:9923 # The sh exporter's hostname:port
```