resource "aws_instance" "bastion" {
  ami             = var.bastion_ami
  instance_type   = var.bastion_instance_type
  subnet_id       = var.public_subnet_id
  key_name        = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "Bastion Host"
  }
}
