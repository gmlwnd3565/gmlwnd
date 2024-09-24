# 1. 이미 존재하는 Transit Gateway 확인
data "aws_ec2_transit_gateway" "existing_tgw" {
  filter {
    name   = "tag:Name"
    values = ["transit-gateway"]
  }
  count = 0  # 에러를 방지하기 위해 count를 0으로 설정
}

# 2. Transit Gateway가 존재하는지 여부를 locals에 저장
locals {
  tgw_exists = length(data.aws_ec2_transit_gateway.existing_tgw) > 0
}

# 3. Transit Gateway가 없을 경우에만 새로 생성
resource "aws_ec2_transit_gateway" "this" {
  count                           = local.tgw_exists ? 0 : 1
  description                     = "Transit Gateway for VPC communication"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "transit-gateway"
  }
}

data "aws_ec2_transit_gateway_vpc_attachment" "existing_dev_vpc_attachment" {
  filter {
    name   = "vpc-id"
    values = [var.dev_vpc_id]
  }
  count = 0
}

locals {
  dev_vpc_attached = length(data.aws_ec2_transit_gateway_vpc_attachment.existing_dev_vpc_attachment) > 0
  transit_gateway_id = local.tgw_exists ? data.aws_ec2_transit_gateway.existing_tgw[0].id : aws_ec2_transit_gateway.this[0].id
}

# 4. Dev VPC Attachment - 이미 존재하는 Transit Gateway 또는 새로 생성된 Transit Gateway 사용
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_vpc" {
  count              = local.dev_vpc_attached ? 0 : 1  # 이미 연결된 경우 생성하지 않음
  subnet_ids         = var.dev_subnet_ids
  vpc_id             = var.dev_vpc_id
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id

  tags = {
    Name = "dev-vpc-attachment"
  }
}

data "aws_ec2_transit_gateway_vpc_attachment" "existing_prod_vpc_attachment" {
  filter {
    name   = "vpc-id"
    values = [var.prod_vpc_id]
  }
  count = 0
}

locals {
  prod_vpc_attached = length(data.aws_ec2_transit_gateway_vpc_attachment.existing_prod_vpc_attachment) > 0
  transit_gateway_id = local.tgw_exists ? data.aws_ec2_transit_gateway.existing_tgw[0].id : aws_ec2_transit_gateway.this[0].id
}


# 5. Prod VPC Attachment - 이미 존재하는 Transit Gateway 또는 새로 생성된 Transit Gateway 사용
resource "aws_ec2_transit_gateway_vpc_attachment" "prod_vpc" {
  count              = local.prod_vpc_attached ? 0 : 1  # 이미 연결된 경우 생성하지 않음
  subnet_ids         = var.prod_subnet_ids
  vpc_id             = var.prod_vpc_id
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id

  tags = {
    Name = "prod-vpc-attachment"
  }
}
