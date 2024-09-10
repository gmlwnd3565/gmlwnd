output "bastion_instance_id" {
  description = "The Bastion Host instance ID"
  value       = aws_instance.bastion.id
}
