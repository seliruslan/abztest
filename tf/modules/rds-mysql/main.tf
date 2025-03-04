resource "aws_security_group" "aws_db_sg" {
  vpc_id = var.aws_vpc_id

}
resource "aws_db_instance" "aws_db_instance_free" {
  identifier        = "wordpress-db"
  db_name           = var.db_name
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password

  vpc_security_group_ids = [aws_security_group.aws_db_sg.id]
  db_subnet_group_name   = var.db_subnet_group_name

  skip_final_snapshot = true
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  multi_az            = false
  publicly_accessible = false
  deletion_protection = false

  storage_encrypted = false
}
