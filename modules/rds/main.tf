# 1. 이미 존재하는 RDS 확인
data "aws_db_instance" "existing_rds" {
  db_instance_identifier = var.db_name
  count = 0  # 데이터 소스가 에러를 발생시키지 않도록 기본적으로 count를 0으로 설정
}

# 2. RDS 존재 여부를 locals에 저장
locals {
  rds_exists = length(data.aws_db_instance.existing_rds) > 0
}

# 3. RDS Subnet Group 생성 - RDS가 없을 경우에만 생성
resource "aws_db_subnet_group" "rds_subnet_group" {
  count      = local.rds_exists ? 0 : 1  # RDS가 없을 경우에만 서브넷 그룹 생성
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_group

  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  count                = local.rds_exists ? 0 : 1
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
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group[0].name
}
