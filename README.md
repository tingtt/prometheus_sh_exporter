# Linux Shell Exporter

The linux shell exporter allows probing with shell scripts.

## Get started

Download the most suitable binary from [the releases tab](/release).

### Run from binaries

```bash
./prometheus-linux-shell-exporter -port 9923 -config.file linuxsh.yml
```

### Run as systemd service

```bash
make install \
  BIN_DIR=/usr/local/bin \
  ETC_DIR=/etc/prometheus-linux-shell-exporter \
  ETC_SH_DIR=/etc/prometheus-linux-shell-exporter/sh \
  SYSTEMD_UNIT_DIR=/lib/systemd/system \
  EXPOSE_PORT=9923

systemctl enable --now prometheus-linux-shell-exporter.service
```

## Configuration

Example config:

```yaml
metrics:
  - name: last_backup_time # Metric name
    label: gitlab # Metric label
    shpath: "/etc/prometheus-linux-shell-exporter/sh/sample_last_gitlab_backup_time.sh" # Absolute path to shell script file
    help: "Unix time of last gitlab backup was made." # Metric help message
    type: gauge # Metric type
  - name: last_backup_time
    label: gitlab-etc
    shpath: "/etc/prometheus-linux-shell-exporter/sh/sample_last_gitlabetc_backup_time.sh"
    help: "Unix time of last gitlab-etc backup was made."
    type: gauge
```

```bash
systemctl restart prometheus-linux-shell-exporter.service

curl localhost:9923/metrics

# HELP last_backup_time Unix time of last gitlab backup was made.
# TYPE last_backup_time gauge
last_backup_time{label=gitlab} ...
# HELP last_backup_time Unix time of last gitlab-etc backup was made.
# TYPE last_backup_time gauge
last_backup_time{label=gitlab-etc} ...
```

```yaml:prometheus.yml
scrape_configs:
  - job_name: linuxsh
    static_configs:
      - targets:
          - 127.0.0.1:9923 # The linux shell exporter's hostname:port
```