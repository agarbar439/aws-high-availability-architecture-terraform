resource "aws_efs_file_system" "main" {
  creation_token = var.efs-token

  performance_mode = var.efs-performance-mode
  throughput_mode  = var.efs-throughput-mode        

  lifecycle_policy {
    transition_to_ia = var.efs-lifecycle-transition-to-ia  # Move files to Infrequent Access after 30 days
  }

  lifecycle_policy {
    transition_to_primary_storage_class = var.efs-lifecycle-transition-to-primary-storage-class  # Move back on first access
  }

  tags = {
    Name        = var.efs-name
  }
}

resource "aws_efs_mount_target" "main" {
  count = length(local.filtered_subnets)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = local.filtered_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

