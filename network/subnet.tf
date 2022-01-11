# ----------------------------------
# subnet for ROLE_NAME
# ----------------------------------

resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = var.public_subnet_1a
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.service_domain}-public_subnet_1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

output "public_subnet_1a" {
  value = aws_subnet.public_subnet_1a.id
}

# ----------------------------------
# route table for ROLE_NAME
# ----------------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.service_domain}-public-rt"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

resource "aws_route_table_association" "public_rt_1a" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet_1a.id
}

# ----------------------------------
# internet gateway for ROLE_NAME
# ----------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.service_domain}-igw"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_route" "public_rt_igw_r" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
