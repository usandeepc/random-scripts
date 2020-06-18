#!/bin/bash

#Script to Download and install Node Exporter in Linux with systemd
#Download Node exporter

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar -xvzf node_exporter-1.0.1.linux-amd64.tar.gz
mv node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/
sudo useradd -rs /bin/false node_exporter

#Node exporter systemd

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

#Start and enable Node exporter service

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
systemctl status node_exporter
