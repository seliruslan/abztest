variable "aws_region" {
  type    = string
  default = "eu-west-1"
}
variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "aws_subnet_public_cidr1" {
  type    = string
  default = "10.0.1.0/24"
}
variable "aws_subnet_public_cidr2" {
  type    = string
  default = "10.0.2.0/24"
}
variable "aws_subnet_private_cidr1" {
  type    = string
  default = "10.0.3.0/24"
}
variable "aws_subnet_private_cidr2" {
  type    = string
  default = "10.0.4.0/24"
}
variable "db_username" {
  type    = string
  default = "seliruslan"
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_name" {
  type    = string
  default = "wordpress"
}
variable "public_key_path" {
  type      = string
  sensitive = true
}
variable "private_key_path" {
  type      = string
  sensitive = true
}