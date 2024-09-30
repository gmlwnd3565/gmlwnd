resource "aws_db_subnet_group" "rds_subnet_group" {
  count = var.subnet_group_name == "" ? 1 : 0  # 서브넷 그룹이 없을 때만 생성

  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_ids

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
  identifier             = var.instance_identifier
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot = true
  # count를 사용한 리소스를 인덱스로 참조
  db_subnet_group_name = length(aws_db_subnet_group.rds_subnet_group) > 0 ? aws_db_subnet_group.rds_subnet_group[0].name : var.subnet_group_name
}
