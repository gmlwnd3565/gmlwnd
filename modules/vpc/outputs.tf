output "vpc_id" {
  value = local.vpc_exists ? data.aws_vpc.existing_vpc[0].id : aws_vpc.main[0].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}
