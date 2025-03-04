module "vpc" {
  source                   = "./tf/modules/vpc"
  aws_vpc_cidr             = var.aws_vpc_cidr
  aws_subnet_public_cidr1  = var.aws_subnet_public_cidr1
  aws_subnet_public_cidr2  = var.aws_subnet_public_cidr2
  aws_subnet_private_cidr1 = var.aws_subnet_private_cidr1
  aws_subnet_private_cidr2 = var.aws_subnet_private_cidr2
}
module "iam" {
  source = "./tf/modules/iam"

  iam_user_name = "readonly-user"

}
module "aws_alb" {
  source     = "./tf/modules/aws_alb"
  aws_vpc_id = module.vpc.aws_vpc

  aws_subnet_public_id1 = module.vpc.aws_subnet_public1
  aws_subnet_public_id2 = module.vpc.aws_subnet_public2


  depends_on = [
    module.vpc
  ]
}
module "rds-mysql" {
  source               = "./tf/modules/rds-mysql"
  aws_vpc_id           = module.vpc.aws_vpc
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = module.vpc.db_subnet_group_name

  depends_on = [
    module.vpc
  ]
}
module "ec_redis" {
  source                       = "./tf/modules/ec_redis"
  aws_vpc_id                   = module.vpc.aws_vpc
  aws_elasticache_subnet_group = module.vpc.aws_elasticache_subnet_group_name


  depends_on = [
    module.vpc
  ]
}
module "ec2" {
  source     = "./tf/modules/ec2"
  aws_vpc_id = module.vpc.aws_vpc

  aws_db_sg_id            = module.rds-mysql.aws_db_sg_id
  aws_redis_sg_id         = module.ec_redis.aws_redis_sg_id
  private_subnet_id       = module.vpc.aws_subnet_private
  public_key_path         = var.public_key_path
  private_key_path        = var.private_key_path
  target_group_public_arn = module.aws_alb.target_group_arn
  aws_lb_sg_id            = module.aws_alb.aws_lb_sg_id
  site_url                = module.aws_alb.alb_dns_name
  db_endpoint             = module.rds-mysql.db_endpoint
  db_name                 = "wordpress"
  db_username             = var.db_username
  db_password             = var.db_password

  redis_endpoint = module.ec_redis.redis_endpoint
  redis_port     = module.ec_redis.redis_port

  depends_on = [
    module.vpc,
    module.rds-mysql,
    module.ec_redis,
    module.aws_alb
  ]
}
