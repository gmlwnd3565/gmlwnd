resource "aws_db_instance" "default" {
  identifier              = var.db_identifier
  allocated_storage       = 20
  engine                  = var.db_engine
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = true  # 퍼블릭 액세스 설정
  vpc_security_group_ids  = [var.security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  skip_final_snapshot     = true

  tags = {
    Name = var.db_name
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}
