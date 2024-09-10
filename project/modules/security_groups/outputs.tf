# modules/security-group/outputs.tf
output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "nat_sg_id" {
  value = aws_security_group.nat_sg.id
}