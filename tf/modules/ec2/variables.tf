variable "public_key_path" {
  type = string
}
variable "aws_vpc_id" {
  type = string
}
variable "private_subnet_id" {
  type = string
}
variable "private_key_path" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}
variable "redis_endpoint" {
  type = string
}
variable "redis_port" {
  type    = string
  default = "6379"
}
variable "target_group_public_arn" {
  type = string
}
variable "site_url" {
  type = string
}
variable "aws_lb_sg_id" {
  type = string
}
variable "aws_db_sg_id" {
  type = string
}
variable "aws_redis_sg_id" {
  type = string
}
