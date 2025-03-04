output "db_endpoint" {
  value = aws_db_instance.aws_db_instance_free.endpoint
}

output "aws_db_sg_id" {
  value = aws_security_group.aws_db_sg.id
}