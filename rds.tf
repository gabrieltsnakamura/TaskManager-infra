resource "aws_db_instance" "task-manager-db" {
  identifier             = "task-manager"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  allocated_storage      = 10
  storage_type           = "gp2"
  username               = "admin"
  password               = "admin1234"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.task-manager-db-sg.id]

  tags = {
    Name = "task-manager-db"
  }
}

resource "aws_security_group" "task-manager-db-sg" {
  name_prefix = "task-manager-db-sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}