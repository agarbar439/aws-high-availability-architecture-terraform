// Security group for the Application Load Balancer (ALB)
resource "aws_security_group" "alb_sg" {
  name        = var.name_sg_alb 
  description = "Security group for the Application Load Balancer" 
  vpc_id      = data.aws_vpc.default_vpc.id // VPC ID for the security group

  // Inbound rules
  ingress {
    from_port   = var.application_port     # Port range for the rule
    to_port     = var.application_port     # Port range for the rule
    protocol    = "tcp"                     # Protocol 
    cidr_blocks = [var.cidr_block]          # Allowed IP address range
  }

  // Outbound rules
  egress {
    from_port   = var.port_alb_outbound
    to_port     = var.port_alb_outbound
    protocol    = "-1"                      // Allow all outbound traffic
    cidr_blocks = [var.cidr_block]          // Allowed IP address range
  }
}

// Security group for the EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg" 
  description = "Security group for EC2 instances" 
  vpc_id      = data.aws_vpc.default_vpc.id // VPC ID for the security group

  // Inbound rules
  // Allow traffic from the ALB security group to the EC2 instances
  ingress {
    from_port   = var.application_port     
    to_port     = var.application_port     
    protocol    = "tcp"                  
    security_groups = [aws_security_group.alb_sg.id] 
  }

// Security group for SSH access to EC2 instances
  ingress {
    from_port   = 22                     
    to_port     = 22                     
    protocol    = "tcp"                  
    cidr_blocks = [var.cidr_block]     
  }

  // Outbound rules
  // Allow all outbound traffic from the EC2 instances
 egress {
    from_port   = var.port_ec2_outbound
    to_port     = var.port_ec2_outbound
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
}

}

// Security group for the EFS file system
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg" 
  description = "Security group for EFS file system" 
  vpc_id      = data.aws_vpc.default_vpc.id // VPC ID for the security group

  // Inbound rules
  // Allow NFS traffic from the EC2 instances to the EFS file system
  ingress {
    from_port   = 2049                    
    to_port     = 2049                    
    protocol    = "tcp"                  
    security_groups = [aws_security_group.ec2_sg.id] 
  }

  // Outbound rules
  // Allow all outbound traffic from the EFS file system
  egress {
    from_port   = var.port_ec2_outbound
    to_port     = var.port_ec2_outbound
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
}

tags = {
    Name = "efs-sg"
  }
}