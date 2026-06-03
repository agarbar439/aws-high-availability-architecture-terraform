// ACM Certificate for the domain
resource "aws_acm_certificate" "main" {
    domain_name       = var.domain_name
    validation_method = "DNS"
    
    tags = {
        Environment = var.environment
        Name = "${var.domain_name}-certificate"
    }

    lifecycle {
        create_before_destroy = true
    }
}