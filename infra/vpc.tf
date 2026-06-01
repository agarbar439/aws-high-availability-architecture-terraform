// This file defines the VPC and subnets to be used by the infrastructure.
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

// Output the VPC ID and subnet IDs for reference
data "aws_subnet" "subnet_details" {
  for_each = toset(data.aws_subnets.default_subnets.ids)
  id       = each.value
}

// Avoid using subnets in the "us-east-1e" availability zone for the ALB and ASG
locals {
  filtered_subnets = [
    for subnet in data.aws_subnet.subnet_details :
    subnet.id
    if subnet.availability_zone != "us-east-1e"
  ]
}

