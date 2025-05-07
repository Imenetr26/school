#!/bin/bash

# Mettre à jour les paquets
sudo apt-get update -y
sudo apt-get upgrade -y

# Installer Java
sudo apt-get install openjdk-17-jdk -y

# Installer Docker
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker vagrant

# Installer Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Installer PostgreSQL pour SonarQube
sudo apt-get install postgresql postgresql-contrib -y
sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"

# Installer SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.4.87374.zip
sudo apt-get install unzip -y
unzip sonarqube-9.9.4.87374.zip
sudo mv sonarqube-9.9.4.87374 /opt/sonarqube

# Configurer SonarQube (minimal)
sudo useradd sonar
sudo chown -R sonar:sonar /opt/sonarqube
sudo bash -c 'cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube
After=network.target

[Service]
Type=simple
User=sonar
Group=sonar
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube
echo "Test webhook - $(date)"

