resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "Bastion-Host"
  }

  vpc_security_group_ids = [var.security_group_id]
}
