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