resource "aws_vpc" "main" {

  cidr_block = var.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

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

# 8. EIP 생성 - NAT 게이트웨이가 생성된 후에 실행
resource "aws_eip" "nat" {
  vpc = true
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id  # NAT 게이트웨이를 경유
  }

  tags = {
    Name = "${var.name}-private-route-table"
  }
}

# 퍼블릭 서브넷의 라우팅 테이블 (인터넷 게이트웨이 사용)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id  # 인터넷 게이트웨이를 경유
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