resource "aws_security_group" "aws_redis_sg" {
  vpc_id = var.aws_vpc_id
}
resource "aws_elasticache_cluster" "ec_redis" {
  cluster_id           = "ecredis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.0"
  port                 = 6379

  security_group_ids = [aws_security_group.aws_redis_sg.id]
  subnet_group_name  = var.aws_elasticache_subnet_group

  az_mode = "single-az"
}
