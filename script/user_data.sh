#!/bin/bash
set -e

# =========================
# Atualiza pacotes
# =========================
apt-get update -y

# =========================
# Instala Nginx (opcional)
# =========================
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# =========================
# Instala Prometheus Server
# =========================
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

PROM_VERSION="2.53.1"
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar -xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
mv prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
mv prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
mv prometheus-${PROM_VERSION}.linux-amd64/consoles /etc/prometheus
mv prometheus-${PROM_VERSION}.linux-amd64/console_libraries /etc/prometheus
mv prometheus-${PROM_VERSION}.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool /etc/prometheus

cat <<EOT > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

# =========================
# Instala Node Exporter
# =========================
useradd --no-create-home --shell /bin/false node_exporter

NODE_EXPORTER_VERSION="1.8.2"
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

cat <<EOT > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# =========================
# Ajusta Prometheus para coletar Node Exporter
# =========================
cat <<EOT > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node"
    static_configs:
      - targets: ["localhost:9100"]
EOT

systemctl restart prometheus

# =========================
# Instala Grafana (via repo oficial)
# =========================
apt-get install -y software-properties-common adduser libfontconfig1 musl
wget -q -O /usr/share/keyrings/grafana.gpg https://packages.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list

apt-get update -y
apt-get install -y grafana

# =========================
# Corrige systemd do Grafana
# =========================
cat <<EOT > /etc/systemd/system/grafana-server.service
[Unit]
Description=Grafana instance
Wants=network-online.target
After=network-online.target

[Service]
User=grafana
Group=grafana
Type=simple
ExecStart=/usr/sbin/grafana-server \\
  --homepath=/usr/share/grafana \\
  --config=/etc/grafana/grafana.ini \\
  --packaging=deb \\
  cfg:default.paths.data=/var/lib/grafana \\
  cfg:default.paths.logs=/var/log/grafana \\
  cfg:default.paths.plugins=/var/lib/grafana/plugins \\
  cfg:default.paths.provisioning=/etc/grafana/provisioning
Restart=always
LimitNOFILE=65536
TimeoutStopSec=20
KillMode=process

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server