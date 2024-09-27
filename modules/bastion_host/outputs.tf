output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

# Bastion Host의 Public IP 출력
output "public_ip" {
  description = "The public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip  # Bastion 호스트 인스턴스의 public_ip 속성
}
