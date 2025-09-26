resource "aws_vpc" "PublicVPC" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "PublicSubnet" {
  vpc_id                  = aws_vpc.PublicVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "PublicIGW" {
  vpc_id = aws_vpc.PublicVPC.id
}

resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.PublicVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PublicIGW.id
  }
}

resource "aws_route_table_association" "RTA1" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
}

resource "aws_security_group" "MySG" {
  vpc_id = aws_vpc.PublicVPC.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API Server
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal communication (within VPC)
  ingress {
    description = "Allow all traffic within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "WorkerNode1" {
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.MySG.id]
  associate_public_ip_address = true

  tags = {
    Name = "WorkerNode1"
  }
}

resource "aws_instance" "WorkerNode2" {
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.MySG.id]
  associate_public_ip_address = true

  tags = {
    Name = "WorkerNode2"
  }
}

resource "aws_instance" "MasterNode" {
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.MySG.id]
  associate_public_ip_address = true

  user_data = <<-EOT
              #!/bin/bash
              set -e

              # Update system
              apt-get update -y
              apt-get upgrade -y

              # Install dependencies
              apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

              # Install containerd
              apt-get install -y containerd
              mkdir -p /etc/containerd
              containerd config default | tee /etc/containerd/config.toml
              sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
              systemctl restart containerd
              systemctl enable containerd

              # Disable swap
              swapoff -a
              sed -i '/ swap / s/^/#/' /etc/fstab

              # Enable kernel modules
              modprobe overlay
              modprobe br_netfilter
              cat <<EOTMODULES | tee /etc/modules-load.d/k8s.conf
              overlay
              br_netfilter
              EOTMODULES

              # Sysctl settings
              cat <<EOTSYSCTL | tee /etc/sysctl.d/k8s.conf
              net.bridge.bridge-nf-call-iptables = 1
              net.ipv4.ip_forward = 1
              net.bridge.bridge-nf-call-ip6tables = 1
              EOTSYSCTL
              sysctl --system

              # Install Kubernetes binaries
              curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
              echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubelet kubeadm kubectl
              apt-mark hold kubelet kubeadm kubectl
              EOT

  tags = {
    Name = "MasterNode"
  }
}
