# 3. RDS Subnet Group 생성 - RDS가 없을 경우에만 생성
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_group

  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  publicly_accessible  = true
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot = true
  # 여기에 단일 문자열인 subnet group 이름을 전달
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}
