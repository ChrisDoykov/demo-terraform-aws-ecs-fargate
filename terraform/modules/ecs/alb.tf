# Application Load Balancer in public subnets with HTTP default listener that redirects traffic to HTTPS

resource "aws_lb" "alb" {
  provider           = aws.main
  name               = "${var.namespace}-ALB-${var.environment}"
  security_groups    = [aws_security_group.alb.id]
  load_balancer_type = "application"
  subnets            = var.public_subnets

  depends_on = [aws_security_group.alb]
}

# SG for ALB

resource "aws_security_group" "alb" {
  provider    = aws.main
  name        = "${var.namespace}_ALB_SecurityGroup_${var.environment}"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}_ALB_SecurityGroup_${var.environment}"
  }
}

# We only allow incoming traffic on HTTPS from known CloudFront CIDR blocks

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "alb_cloudfront_https_ingress_only" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS access only from CloudFront CIDR blocks"
  from_port         = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  to_port           = 443
  type              = "ingress"
}

# Default HTTPS listener that blocks all traffic without valid custom origin header

resource "aws_lb_listener" "alb_default_listener_https" {
  provider          = aws.main
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.alb_certificate_validation.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }

  depends_on = [aws_acm_certificate_validation.alb_certificate_validation]
}

# HTTPS Listener Rule to only allow traffic with a valid custom origin header coming from CloudFront

resource "aws_lb_listener_rule" "https_listener_rule" {
  provider     = aws.main
  listener_arn = aws_lb_listener.alb_default_listener_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target_group.arn
  }

  condition {
    host_header {
      values = ["${var.environment}.${var.domain_name}"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = [var.custom_origin_host_header_value]
    }
  }
}

# Creates the Target Group for our service

resource "aws_lb_target_group" "service_target_group" {
  provider             = aws.main
  name                 = "${var.namespace}-TargetGroup-${var.environment}"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 5
  target_type          = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    matcher             = var.healthcheck_matcher
    path                = var.healthcheck_endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
  }

  depends_on = [aws_lb.alb]
}