resource "aws_ec2_transit_gateway" "this" {
  description = "Transit Gateway"
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = {
    Name = "transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev_vpc" {
  subnet_ids         = var.dev_subnet_ids
  vpc_id             = var.dev_vpc_id
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name = "dev-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod_vpc" {
  subnet_ids         = var.prod_subnet_ids
  vpc_id             = var.prod_vpc_id
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = {
    Name = "prod-vpc-attachment"
  }
}

