provider "aws" {
  region = var.aws_region
}

# Latest Amazon Linux 2023 AMI for the selected region.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# Security group: HTTP for users, SSH for deployment.
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP and SSH"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Basic IAM role attached to the EC2 instance.
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 virtual machine that runs Nginx and serves the static website.
resource "aws_instance" "web" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.web_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data = <<-USERDATA
  #!/bin/bash
  set -e
  yum update -y
  yum install -y nginx
  systemctl start nginx
  systemctl enable nginx
  rm -rf /usr/share/nginx/html/*
  cat > /usr/share/nginx/html/index.html << 'PLACEHOLDER'
  <!DOCTYPE html>
  <html><head><title>Deploying...</title></head>
  <body style="font-family:sans-serif;text-align:center;padding:80px;background:#0a0f1e;color:#e2e8f0">
    <h1 style="color:#3b82f6">EC2 is ready</h1>
    <p>CI/CD pipeline will deploy the real site shortly.</p>
  </body></html>
  PLACEHOLDER
  chown -R nginx:nginx /usr/share/nginx/html
  chmod -R 755 /usr/share/nginx/html
USERDATA

  tags = {
    Name = "${var.project_name}-web-server"
  }
}
