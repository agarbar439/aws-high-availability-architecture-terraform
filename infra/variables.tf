// AWS Region 
variable "region" {
    type = string
    default = "us-east-1"
}

variable "name_alb" {
    type = string
    default = "app-alb"
}

// Security groups
// Name of the security group for the ALB
variable "name_sg_alb" {
    type = string
    default = "alb-sg"
}

// Port for the application running behind the ALB
variable "application_port" {
    type = number
    default = 80
}

// CIDR block for allowing traffic 
variable "cidr_block" {
    type = string
    default = "0.0.0.0/0"
}
 // Port for outbound traffic from EC2 instances
variable "port_ec2_outbound" {
    type = number
    default = 0
}

// Port for outbound traffic from the ALB
variable "port_alb_outbound" {
    type = number
    default = 0
}

// EC2 instance variables
variable "ec2-name" {
    type = string
    default = "web-server"
}

variable "ec2-ami"{
    type = string
    default = "ami-00e801948462f718a"
}

variable "ec2-instance-type"{
    type = string
    default = "t3.micro"
}

variable "ec2-min-count"{
    type = number
    default = 2
}

variable "ec2-desired-count"{
    type = number
    default = 2
}

variable "ec2-max-count"{
    type = number
    default = 3
}

variable "ec2-key-name"{
    type = string
    default = "demo_par_claves"
}


// Protocol for the ALB and target group
variable "protocol" {
    type = string
    default = "HTTP"
}

// EFS
variable "efs-name" {
    type = string
    default = "shared-storage-ec2"
}

variable "efs-performance-mode" {
    type = string
    default = "generalPurpose"  // General purpose performance mode for most workloads
}

variable "efs-throughput-mode" {
    type = string
    default = "bursting"        // Bursting throughput mode for most workloads
}

variable efs-token {
    type = string
    default = "shared-storage-ec2"
}

variable efs-lifecycle-transition-to-ia {
    type = string
    default = "AFTER_30_DAYS"  // Move files to Infrequent Access after 30 days
}

variable "efs-lifecycle-transition-to-primary-storage-class" {
    type = string
    default = "AFTER_1_ACCESS"  // Move back to primary storage class on first access
}