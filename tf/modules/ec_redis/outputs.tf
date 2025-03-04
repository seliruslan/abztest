output "redis_endpoint" {
  value = aws_elasticache_cluster.ec_redis.cache_nodes[0].address
}

output "redis_port" {
  value = aws_elasticache_cluster.ec_redis.port
}
output "aws_redis_sg_id" {
  value = aws_security_group.aws_redis_sg.id
}