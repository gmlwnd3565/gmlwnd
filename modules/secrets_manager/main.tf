resource "aws_secretsmanager_secret" "secret" {
  name = var.secret_name

  description = var.description

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    username             = var.username
    password             = var.password
    engine               = var.engine
    host                 = var.host
    port                 = var.port
    dbname               = var.dbname
    dbInstanceIdentifier = var.db_instance_identifier
  })
}
