#!/bin/bash

Pre-Requisites 
groupadd --system prometheus
useradd -s /sbin/nologin -r -g prometheus prometheus
mkdir -p /etc/prometheus/{rules,rules.d,files_sd}  /var/lib/prometheus

#Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.19.0.linux-amd64.tar.gz
cd prometheus-2.19.0.linux-amd64
cp prometheus promtool /usr/local/bin/
cp -r consoles/ console_libraries/ /etc/prometheus/


cat <<EOF > /etc/prometheus/prometheus.yml
global: 
 scrape_interval: 15s
 evaluation_interval: 15s
 scrape_timeout: 15s

scrape_configs:
 - job_name: 'prometheus'
   static_configs:
       - targets: ['localhost:9090']
# - job_name: 'nodes'
#   file_sd_configs:
#   - files:
#       - '/etc/prometheus/files_sd/sd.json'
EOF

chown -R prometheus:prometheus /etc/prometheus/  /var/lib/prometheus/
chmod -R 775 /etc/prometheus/ /var/lib/prometheus/

#Install as a Service
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus systemd service unit
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
