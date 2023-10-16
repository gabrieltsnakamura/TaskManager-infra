terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "taskmanager-bucket"
    key    = "terraform-statefiles/taskManager-infra.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_iam_instance_profile" "task_manager_codedeploy_instance_profile" {
  name = "task_manager_codedeploy_instance_profile"
  role = aws_iam_role.task_manager_codedeploy_instance_role.name
}

resource "aws_iam_role" "task_manager_codedeploy_instance_role" {
  name = "task_manager_codedeploy_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "codedeploy-role"
  }
}

resource "aws_iam_policy" "task_manager_codedeploy_instance_policy" {
  name        = "task_manager_codedeploy_instance_policy"
  policy      = data.aws_iam_policy_document.task_manager_codedeploy_instance_policy.json
  description = "Allows CodeDeploy to deploy"
}

data "aws_iam_policy_document" "task_manager_codedeploy_instance_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "task_manager_codedeploy_policy_attachment" {
  policy_arn = aws_iam_policy.task_manager_codedeploy_instance_policy.arn
  role       = aws_iam_role.task_manager_codedeploy_instance_role.name
}

resource "aws_launch_template" "task_manager_lc" {
  name_prefix            = "task_manager_lc_"
  image_id               = "ami-0af6e9042ea5a4e3e"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.task_manager_nginx_sg.id]
  user_data              = filebase64("nginx-install.sh")
  iam_instance_profile {
    arn = "${aws_iam_instance_profile.task_manager_codedeploy_instance_profile.arn}"
  }
}

resource "aws_security_group" "task_manager_nginx_sg" {
  name        = "nginx-sg"
  description = "allow ssh on 22 & http on port 443"
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