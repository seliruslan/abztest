output "alb_dns_name" {
  value = aws_lb.aws_lb.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.aws_lb_target_group_public.arn
}
output "aws_lb_sg_id" {
  value = aws_security_group.aws_lb_sg.id
}