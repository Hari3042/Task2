#!/bin/bash

sudo mkdir /opt/Applications
sudo mv ~/locations-postgres.jar /opt/Applications/locations-postgres.jar

# set environment variable      
echo 'PG_DB=postgresdb
PG_USER=postgresuser
PG_PASSWORD=password
_JAVA_OPTIONS=-Dspring.profiles.active=postgres' >>/etc/environment

# update package index and install required packages
sudo apt-get update
sudo apt-get install apache2 default-jdk ca-certificates-java openjdk-17-jre-headless postgresql -y

# create PostgreSQL database and user
sudo -i -u postgres psql -c "CREATE DATABASE postgresdb;"
sudo -i -u postgres psql -c "CREATE USER postgresuser WITH PASSWORD 'password';"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE postgresdb TO postgresuser;"

# Create systemd service
echo "[Unit]
Description=Locations Postgres Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/java -jar /opt/Applications/locations-postgres.jar
Restart=always
User=azure
EnvironmentFile = /etc/environment

[Install]
WantedBy=multi-user.target" >/etc/systemd/system/locations-postgres.service

# Reload systemd configuration
sudo systemctl daemon-reload

# Start and enable the service
sudo systemctl start locations-postgres.service
sudo systemctl enable locations-postgres.service

/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
