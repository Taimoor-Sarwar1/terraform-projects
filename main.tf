# 1. Create VPC
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"

}

# 2. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myVPC.id
}

# 3. Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# 4. Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# 5. Route Table Associations
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Security Group (allow SSH)
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.myVPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. EC2 Instance
resource "aws_instance" "web" {
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
}

# 8. Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = "xyz.com"
}

# 9. Route53 Record (maps xyz.com to EC2 public IP)
resource "aws_route53_record" "web_dns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "xyz.com"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web.public_ip]
}
