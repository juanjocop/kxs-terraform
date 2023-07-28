resource "aws_vpc" "kxs-vpc" {
  cidr_block = var.cidr_block_vpc
  tags = {
    "Name" = "kxs-vpc"
  }
}

resource "aws_subnet" "kxs-subnet" {
  vpc_id            = aws_vpc.kxs-vpc.id
  cidr_block        = var.cidr_block_subnet
  availability_zone = "eu-west-1a"
  tags = {
    "Name" = "kxs-subnet"
  }
}

resource "aws_internet_gateway" "kxs-gateway" {
  vpc_id = aws_vpc.kxs-vpc.id
  tags = {
    "Name" = "kxs-gateway"
  }
}

resource "aws_route_table" "kxs-route" {
  vpc_id = aws_vpc.kxs-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kxs-gateway.id
  }
  tags = {
    "Name" = "kxs-route"
  }
}

resource "aws_route_table_association" "kxs-rta" {
  subnet_id      = aws_subnet.kxs-subnet.id
  route_table_id = aws_route_table.kxs-route.id
}

resource "aws_security_group" "kxs-master-sg" {
  name        = "kxs-master-sg"
  description = "Grupo de seguridad basico del cluster"
  vpc_id      = aws_vpc.kxs-vpc.id

  tags = {
    "app" : "kxs"
  }
}

resource "aws_security_group" "kxs-worker-sg" {
  name        = "kxs-worker-sg"
  description = "Grupo de seguridad basico del cluster"
  vpc_id      = aws_vpc.kxs-vpc.id

  tags = {
    "app" : "kxs"
  }
}

resource "aws_security_group" "kxs-mariadb-sg" {
  name        = "kxs-mariadb-sg"
  description = "Grupo de seguridad basico del cluster"
  vpc_id      = aws_vpc.kxs-vpc.id

  tags = {
    "app" : "kxs"
  }
}
