data "aws_ssm_parameter" "ubuntu_22_04" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "random_password" "ro_password" {
  length           = 8
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "ro_user" {
  length  = 8
  special = false
}
locals {
  ro_username = "readonly-${random_string.ro_user.result}"
}

resource "aws_key_pair" "my_public_key" {
  key_name   = "my_public_key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "wordpress_sg" {
  vpc_id = var.aws_vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.aws_lb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql_rds" {
  security_group_id            = var.aws_db_sg_id
  referenced_security_group_id = aws_security_group.wordpress_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis" {
  security_group_id            = var.aws_redis_sg_id
  referenced_security_group_id = aws_security_group.wordpress_sg.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}


data "template_file" "wp_config" {
  template = file("${path.module}/wp-config.sh")

  vars = {
    site_url    = var.site_url
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = var.db_password
    db_host     = var.db_endpoint
    redis_host  = var.redis_endpoint
    redis_port  = var.redis_port
    ro_username = local.ro_username
    ro_password = random_password.ro_password.result

  }
}

resource "aws_instance" "aws_instance_public" {
  ami             = data.aws_ssm_parameter.ubuntu_22_04.value
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.my_public_key.key_name
  security_groups = [aws_security_group.wordpress_sg.id]
  subnet_id       = var.private_subnet_id

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    encrypted   = true
  }
  monitoring = false
  credit_specification {
    cpu_credits = "standard"
  }
  user_data = data.template_file.wp_config.rendered
}


resource "aws_lb_target_group_attachment" "aws_lb_target_group_attachment_public" {
  target_group_arn = var.target_group_public_arn
  target_id        = aws_instance.aws_instance_public.id
  port             = 80
}
