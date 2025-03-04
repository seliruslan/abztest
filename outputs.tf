output "wordpress_creds" {
  value = {
    admin_user     = module.ec2.wordpress_admin_username
    admin_password = module.ec2.wordpress_admin_password
    ro_user        = module.ec2.wordpress_ro_username
    ro_password    = module.ec2.wordpress_ro_password
  }
  sensitive = true
}

output "iam_readonly_credentials" {
  description = "IAM readonly user credentials"
  value = {
    password = module.iam.readonly_user_password
  }
  sensitive = true
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.aws_alb.alb_dns_name
}