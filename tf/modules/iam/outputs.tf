output "readonly_user_password" {
  value       = aws_iam_user_login_profile.readonly_user_login.password
  sensitive   = true
  description = "Console password for readonly user"
}
