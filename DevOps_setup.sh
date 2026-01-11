#!/bin/bash
set -e

echo "🔹 Updating system..."
sudo apt update -y

echo "🔹 Installing base tools..."
sudo apt install -y curl wget git unzip vim apt-transport-https ca-certificates gnupg lsb-release

echo "🔹 Installing Java 17..."
sudo apt install -y openjdk-17-jdk
java -version

echo "🔹 Installing Maven..."
sudo apt install -y maven

echo "🔹 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins || true

echo "🔹 Installing Jenkins (WAR)..."
sudo useradd -m jenkins || true
cd /opt
sudo wget -q https://get.jenkins.io/war-stable/latest/jenkins.war
sudo chown jenkins:jenkins /opt/jenkins.war

sudo tee /etc/systemd/system/jenkins.service <<EOF
[Unit]
Description=Jenkins
After=network.target

[Service]
User=jenkins
WorkingDirectory=/opt
ExecStart=/usr/lib/jvm/java-17-openjdk-amd64/bin/java -jar /opt/jenkins.war
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "🔹 Installing SonarQube..."
docker run -d --name sonar -p 9000:9000 sonarqube:lts || true

echo "🔹 Installing Nexus..."
docker run -d --name nexus -p 8081:8081 sonatype/nexus3 || true

echo "🔹 Installing kubectl..."
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "🔹 Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

echo "🔹 Starting Minikube..."
minikube start

echo "🔹 Copy kubeconfig for Jenkins..."
sudo mkdir -p /home/jenkins/.kube
sudo cp /home/ubuntu/.kube/config /home/jenkins/.kube/config
sudo chown -R jenkins:jenkins /home/jenkins/.kube

echo "✅ All DevOps tools installed successfully!"
echo ""
echo "Jenkins:   http://<EC2-IP>:8080"
echo "SonarQube: http://<EC2-IP>:9000"
echo "Nexus:     http://<EC2-IP>:8081"
