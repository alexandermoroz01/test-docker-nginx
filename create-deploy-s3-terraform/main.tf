terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Провайдер
      version = "~> 5.0" # Версія від 5 до 6, але не включаючи 6
    }
  }

  required_version = ">= 1.11.4" # Мінімальна версія терраформа
}

provider "aws" {
  region  = "eu-north-1"
}

# Створення груп security щоб був доступ до сайту, тд відкриттся портів
resource "aws_security_group" "allow_ssh_http_https" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALL
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
user_data = file("setup.sh")

  ami           = "ami-0c1ac8a41498c1a9c"
  instance_type = "t3.micro"
  key_name = "testDockerNginx"

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  security_groups = [aws_security_group.allow_ssh_http_https.name]

  tags = {
    Name = "test-terraform"
  }
}
