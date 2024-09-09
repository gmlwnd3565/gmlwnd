# modules/nat/main.tf
# Create an Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

# Create a NAT Gateway in a public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = var.nat_name
  }
}

# Route table for private subnets to route through NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.vpc_name}-private-route-table"
  }
}

# Associate the private subnets with the NAT route table
resource "aws_route_table_association" "private_subnets" {
  count      = length(var.private_subnet_ids)
  subnet_id  = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}
