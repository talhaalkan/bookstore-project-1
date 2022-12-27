terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "bookstore-server" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  key_name               = "talha"
  vpc_security_group_ids = [aws_security_group.sec-gr.id]
  tags = {
    Name = "Web Server of Bookstore"
  }

  user_data = <<-EOF
              #! /bin/bash
              yum update -y
              yum install git -y
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" \
              -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose         
              hostnamectl set-hostname "docker-compose-bookstore-server"
              cd /home/ec2-user
              git clone https://github.com/talhaalkan/bookstore-project-1.git
              cd /home/ec2-user/bookstore-project-1
              docker build -t bookstore-api:latest .
              docker-compose up -d
              EOF
}