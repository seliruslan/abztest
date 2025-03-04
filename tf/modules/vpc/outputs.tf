output "aws_vpc" {
  value = aws_vpc.aws_vpc.id
}
output "aws_subnet_public1" {
  value = aws_subnet.aws_subnet_public1.id
}
output "aws_subnet_public2" {
  value = aws_subnet.aws_subnet_public2.id
}
output "aws_subnet_private" {
  value = aws_subnet.aws_subnet_private1.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}

output "aws_elasticache_subnet_group_name" {
  value = aws_elasticache_subnet_group.ec_redis_sg.name
}