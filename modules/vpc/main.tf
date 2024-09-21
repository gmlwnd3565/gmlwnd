resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  enable_dns_support   = true   # DNS 해석 활성화
  enable_dns_hostnames = true   # DNS 호스트 이름 활성화

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-public-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route" "dev_to_prod" {
  route_table_id         = aws_route_table.private.id  # 올바른 라우팅 테이블 참조
  destination_cidr_block = var.prod_vpc_cidr
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "prod_to_dev" {
  route_table_id         = aws_route_table.private.id  # 올바른 라우팅 테이블 참조
  destination_cidr_block = var.dev_vpc_cidr
  transit_gateway_id     = var.transit_gateway_id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private-route-table"
  }
}
