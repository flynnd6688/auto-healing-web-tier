locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    docker_image = var.docker_image
  }))
}

# ── Security Group ───────────────────────────────────────────────────────────

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Allow HTTP from ALB only; allow all outbound"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }
}

# ── IAM Role (SSM access – no SSH key needed) ────────────────────────────────

resource "aws_iam_role" "ec2_ssm" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_ssm.name
}

# ── Launch Template ──────────────────────────────────────────────────────────

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = local.user_data

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-web"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group ───────────────────────────────────────────────────────

resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-${var.environment}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"  # ALB health checks drive instance replacement

  # Grace period lets user-data (Docker pull + start) finish before health checks begin
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Replace unhealthy instances automatically (self-healing)
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
