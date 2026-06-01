// Template for autoscaling group
resource "aws_launch_template" "template_ec2" {
  name_prefix            = var.ec2-name
  image_id               = var.ec2-ami
  instance_type          = var.ec2-instance-type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id] // Security group for the EC2 instances

  user_data = base64encode(
    templatefile("../scripts/user_data.sh", {
      efs_id = aws_efs_file_system.main.id // Pass the EFS file system ID to the user data script
    })
  )
  key_name = var.ec2-key-name
}


resource "aws_autoscaling_group" "asg_ec2" {
  name             = "${var.ec2-name}-asg"
  max_size         = var.ec2-max-count
  min_size         = var.ec2-min-count
  desired_capacity = var.ec2-min-count


  termination_policies = ["OldestInstance"] // Terminate the oldest instance first when scaling down
  health_check_type    = "ELB"              // Use ELB health checks for the ASG


  launch_template {
    id      = aws_launch_template.template_ec2.id
    version = "$Latest"

  }
  vpc_zone_identifier = local.filtered_subnets           // Subnets for the ASG (filtered to exclude "us-east-1e")
  target_group_arns   = [aws_lb_target_group.app_tg.arn] // ARN of the target group for the ASG

  tag {
    key                 = "Name"
    value               = "${var.ec2-name}-instance"
    propagate_at_launch = true
  }
}

// Autoscaling policy for scaling down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "test_scale_down"
  autoscaling_group_name = aws_autoscaling_group.asg_ec2.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "test_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  period              = 60

  namespace   = "AWS/AutoScaling"
  metric_name = "GroupAverageCPUUtilization"

  statistic = "Average"
  threshold = 25

  treat_missing_data = "notBreaching" // Treat missing data as not breaching to avoid false alarms when there are no instances

  alarm_actions = [
    aws_autoscaling_policy.scale_down.arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_ec2.name
  }
}

// Autoscaling policy for scaling up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "test_scale_up"
  autoscaling_group_name = aws_autoscaling_group.asg_ec2.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

// Autoscaling policy for scaling up
resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "test_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  period              = 60

  namespace   = "AWS/AutoScaling"
  metric_name = "GroupAverageCPUUtilization"

  statistic = "Average"
  threshold = 50

  treat_missing_data = "notBreaching" // Treat missing data as not breaching to avoid false alarms when there are no instances

  alarm_actions = [
    aws_autoscaling_policy.scale_up.arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_ec2.name
  }
}
