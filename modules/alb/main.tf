resource "aws_security_group" "security-group" {
  name        = "${var.env}-${var.alb-type}-sg"
  description = "${var.env}-${var.alb-type}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.alb_sg_allow_cidr]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.alb_sg_allow_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.alb-type}-sg"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.env}-${var.alb-type}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security-group.id]
  subnets            = var.subnets
  tags = {
    Environment = "${var.env}-${var.alb-type}"
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.alb.dns_name]
}

resource "aws_lb_listener" "listener-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}

resource "aws_lb_listener" "listener-https" {
 count = var.alb-type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:308315242387:certificate/4d8b28b6-b87c-46ef-9ea9-c8ffe1f409f7"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}