resource "aws_security_group" "task_manager_lb_sg" {
  name_prefix = "task_manager_lb_sg_"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "task_manager_lb" {
  name               = "task-manager-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.lb_subnets_id
  security_groups    = [aws_security_group.task_manager_lb_sg.id]
}

resource "random_pet" "app" {
  length    = 2
  separator = "-"
}

resource "aws_lb_target_group" "task_manager_blue" {
  name     = "blue-tg-${random_pet.app.id}-lb"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    port     = 443
    protocol = "HTTPS"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_listener" "task_manager_blue_listener" {
  load_balancer_arn = aws_lb.task_manager_lb.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task_manager_blue.arn
  }
}

resource "aws_lb_target_group" "task_manager_green" {
  name     = "green-tg-${random_pet.app.id}-lb"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    port     = 443
    protocol = "HTTPS"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_listener" "task_manager_green_listener" {
  load_balancer_arn = aws_lb.task_manager_lb.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task_manager_green.arn
  }
}