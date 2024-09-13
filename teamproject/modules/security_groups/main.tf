resource "aws_security_group" "default" {
  name        = var.name
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  # 여러 포트에 대해 규칙 생성
  dynamic "ingress" {
    for_each = var.ingress_port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.protocol
      cidr_blocks = var.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}
