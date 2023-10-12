terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "taskmanager-bucket"
    key    = "terraform-statefiles"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_key_pair" "tf-taskmanager-keypair" {
  key_name   = "tf-taskmanager-keypair"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-taskmanager-keypair"
}


resource "aws_instance" "nginx" {
  depends_on    = [aws_security_group.nginx-sg, aws_key_pair.tf-taskmanager-keypair]
  ami           = "ami-0af6e9042ea5a4e3e"
  instance_type = "t2.micro"
  key_name = aws_key_pair.tf-taskmanager-keypair.key_name
  tags = {
    Name = "task-manager-nginx-server"
  }

  vpc_security_group_ids = [
    "nginx-sg"
  ]

  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = ""
    host     = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}

resource "aws_security_group" "nginx-sg" {
  name        = "nginx-sg"
  description = "allow ssh on 22 & http on port 80"
  vpc_id      = "vpc-01fc95a5350f26011"

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

