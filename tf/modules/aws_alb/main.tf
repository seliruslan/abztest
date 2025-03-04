resource "aws_security_group" "aws_lb_sg" {
  vpc_id = var.aws_vpc_id

}
resource "aws_lb" "aws_lb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws_lb_sg.id]
  subnets            = [var.aws_subnet_public_id1, var.aws_subnet_public_id2]

  enable_deletion_protection = false
}
resource "aws_lb_target_group" "aws_lb_target_group_public" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_lb_target_group_public.arn
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_lb" {
  security_group_id = aws_security_group.aws_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

}
resource "aws_vpc_security_group_ingress_rule" "allow_https_lb" {
  security_group_id = aws_security_group.aws_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

}
resource "aws_vpc_security_group_egress_rule" "allow_egress_all" {
  security_group_id = aws_security_group.aws_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}




