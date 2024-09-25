# 1. 이미 존재하는 VPC 확인
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.name]
  }
  count = 0  # VPC가 없을 때 에러 방지
}

# 2. VPC 존재 여부를 locals에 저장
locals {
  vpc_exists = length(data.aws_vpc.existing_vpc) > 0
}

# 3. VPC가 없을 경우에만 새로 생성
resource "aws_vpc" "main" {
  count      = local.vpc_exists ? 0 : 1
  cidr_block = var.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

# 4. Public 서브넷 생성 - VPC가 생성된 후에만 실행
resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = local.vpc_exists ? data.aws_vpc.existing_vpc[0].id : aws_vpc.main[0].id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.name}-public-${count.index}"
  }
}

# 5. Private 서브넷 생성 - VPC가 생성된 후에만 실행
resource "aws_subnet" "private_subnet" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = local.vpc_exists ? data.aws_vpc.existing_vpc[0].id : aws_vpc.main[0].id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}

# 6. 인터넷 게이트웨이 생성 - VPC가 생성된 후에만 실행
resource "aws_internet_gateway" "igw" {
  count = local.vpc_exists ? 0 : 1  # VPC가 존재할 경우 생성하지 않음
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "${var.name}-igw"
  }
}

# 7. NAT 게이트웨이 생성 - VPC와 서브넷이 생성된 후에만 실행
resource "aws_nat_gateway" "nat" {
  count = local.vpc_exists ? 0 : 1  # VPC가 존재할 경우 생성하지 않음
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

# 8. EIP 생성 - NAT 게이트웨이가 생성된 후에 실행
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "private_route_table" {
  vpc_id = local.vpc_exists ? data.aws_vpc.existing_vpc[0].id : aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[0].id  # NAT 게이트웨이를 경유
  }

  tags = {
    Name = "${var.name}-private-route-table"
  }
}

# 퍼블릭 서브넷의 라우팅 테이블 (인터넷 게이트웨이 사용)
resource "aws_route_table" "public_route_table" {
  vpc_id = local.vpc_exists ? data.aws_vpc.existing_vpc[0].id : aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id  # 인터넷 게이트웨이를 경유
  }

  tags = {
    Name = "${var.name}-public-route-table"
  }
}

# 프라이빗 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# 퍼블릭 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}