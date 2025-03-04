resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}
resource "aws_subnet" "aws_subnet_public1" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = var.aws_subnet_public_cidr1
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
}
resource "aws_subnet" "aws_subnet_public2" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = var.aws_subnet_public_cidr2
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
}
resource "aws_subnet" "aws_subnet_private1" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = var.aws_subnet_private_cidr1
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-1a"

}
resource "aws_subnet" "aws_subnet_private2" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = var.aws_subnet_private_cidr2
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-1b"

}
resource "aws_internet_gateway" "aws_gw" {
  vpc_id = aws_vpc.aws_vpc.id

}
resource "aws_eip" "private_nat" {
  domain = "vpc"
}
resource "aws_nat_gateway" "private_nat_gateway" {
  allocation_id = aws_eip.private_nat.id
  subnet_id     = aws_subnet.aws_subnet_public1.id

  depends_on = [aws_internet_gateway.aws_gw]
}
resource "aws_route_table" "aws_route_table_private" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_nat_gateway.id
  }
}
resource "aws_route_table" "aws_route_table_public" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_gw.id
  }

}
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.aws_subnet_private1.id
  route_table_id = aws_route_table.aws_route_table_private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.aws_subnet_private2.id
  route_table_id = aws_route_table.aws_route_table_private.id
}
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.aws_subnet_public1.id
  route_table_id = aws_route_table.aws_route_table_public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.aws_subnet_public2.id
  route_table_id = aws_route_table.aws_route_table_public.id
}
resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = [aws_subnet.aws_subnet_private1.id, aws_subnet.aws_subnet_private2.id]
}
resource "aws_elasticache_subnet_group" "ec_redis_sg" {
  name       = "ec-redis-sg"
  subnet_ids = [aws_subnet.aws_subnet_private1.id, aws_subnet.aws_subnet_private2.id]
}
