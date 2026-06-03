// Application Load Balancer
resource "aws_lb" "app_lb" {
    name               = var.name_alb
    internal           = false
    ip_address_type    = "ipv4"
    load_balancer_type = "application"
    security_groups = [ aws_security_group.alb_sg.id] // Security group for the ALB

    // Subnets for the ALB (using the default subnets from the VPC)
    subnets = data.aws_subnets.default_subnets.ids

    tags = {
        Name = var.name_alb
    }
}

// Target group for the ALB
resource "aws_lb_target_group" "app_tg" {
    name     = "${var.name_alb}-tg"
    port     = var.application_port
    protocol = var.protocol
    vpc_id   = data.aws_vpc.default_vpc.id // VPC ID for the target group

    health_check {
        path                = "/health" // Health check path for the target group
        protocol            = var.protocol // Protocol for the health check
        matcher             = "200-399" // Expected HTTP status codes for a healthy target
        interval            = 30 // Interval for the health check
        timeout             = 5 // Timeout for the health check
        healthy_threshold   = 2 // Number of successful checks for a healthy target
        unhealthy_threshold = 2 // Number of failed checks for an unhealthy target
    }

    tags = {
        Name = "${var.name_alb}-tg"
    }
}

// Listener for the ALB
resource "aws_lb_listener" "app_listener" {
    load_balancer_arn = aws_lb.app_lb.arn // ARN of the ALB
    port              = var.application_port
    protocol          = var.protocol

    default_action {
        type             = "redirect" // Redirect HTTP to HTTPS
        redirect {
            port        = "443" // Redirect to HTTPS port
            protocol    = "HTTPS" // Redirect to HTTPS protocol
            status_code = "HTTP_301" // Use HTTP 301 for permanent redirect
        }
    }
}

resource "aws_lb_listener" "app_listener_https" {
    load_balancer_arn = aws_lb.app_lb.arn // ARN of the ALB
    port              = 443
    protocol          = "HTTPS"

    ssl_policy        = "ELBSecurityPolicy-2016-08" // SSL policy for the listener
    certificate_arn   = aws_acm_certificate.main.arn // ARN of the ACM certificate

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn // ARN of the target group
    }
}

// Output the DNS name of the ALB
output "alb_dns_name" {
    value = aws_lb.app_lb.dns_name
}

