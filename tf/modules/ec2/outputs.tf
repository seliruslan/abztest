output "aws_instance_public" {
  value = aws_instance.aws_instance_public.id
}
output "private_ip" {
  value = aws_instance.aws_instance_public.private_ip
}
output "wordpress_ro_username" {
  value = local.ro_username
}
output "wordpress_ro_password" {
  value     = random_password.ro_password.result
  sensitive = true
}
output "wordpress_admin_username" {
  value = "admin"
}
output "wordpress_admin_password" {
  value     = var.db_password
  sensitive = true
}