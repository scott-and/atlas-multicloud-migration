# ----------------------------------------------------------------------
# Provider Configuration
# ----------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "atlas-multicloud-migration"
      ManagedBy   = "terraform"
      Environment = "demo"
      Owner       = "scott-anderson"
    }
  }
}

# ----------------------------------------------------------------------
# Networking - VPC
# ----------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "atlas-tf-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name       = "atlas-tf-public-a"
    SubnetType = "public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name       = "atlas-tf-public-b"
    SubnetType = "public"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name       = "atlas-tf-private-a"
    SubnetType = "private"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name       = "atlas-tf-private-b"
    SubnetType = "private"
  }
}

# ----------------------------------------------------------------------
# Networking - Internet Gateway & Routing
# ----------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "atlas-tf-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "atlas-tf-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "atlas-tf-private-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# ----------------------------------------------------------------------
# Security groups
#
# Self note - ingress / egress rules will be kept as separate resources
# instead of inline to prevent conflicting rules and import/export better
# 
# Egress filtering not impl. here, but applicable in prod environments
# ----------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "atlas-tf-alb-sg"
  description = "allows traffic from internet to the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "atlas-tf-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "atlas-tf-ec2-sg"
  description = "allows HTTP traffic from ALB to EC2 instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "atlas-tf-ec2-sg"
  }
}

# Security group ingress rules ----------------------------------------

resource "aws_vpc_security_group_ingress_rule" "allow_alb_http_traffic_from_internet" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ec2_ingress_from_alb" {
  security_group_id            = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Security group egress rules -----------------------------------------

resource "aws_vpc_security_group_egress_rule" "ec2_egress_all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ----------------------------------------------------------------------
# AMI Data Source Lookup
# ----------------------------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ----------------------------------------------------------------------
# EC2 Launch Template
#
# name_prefix used instead of name for clean rollover / updates
# ----------------------------------------------------------------------

resource "aws_launch_template" "web" {
  name_prefix   = "atlas-tf-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  user_data     = base64encode(file("./user-data.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "atlas-tf-web"
    }
  }

}

# ----------------------------------------------------------------------
# Target Group
# ----------------------------------------------------------------------

resource "aws_lb_target_group" "web" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  name        = "atlas-tf-web-tg"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ----------------------------------------------------------------------
# ALB / Listener
# ----------------------------------------------------------------------

resource "aws_lb" "web" {
  name               = "atlas-tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ----------------------------------------------------------------------
# ASG / Policy
# ----------------------------------------------------------------------

resource "aws_autoscaling_group" "web" {
  name                      = "atlas-tf-web-asg"
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "atlas-tf-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 50.0

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

# ----------------------------------------------------------------------
# IAM Roles
# ----------------------------------------------------------------------
resource "aws_iam_role" "ec2_ssm" {
  name = "atlas-tf-ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "atlas-tf-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}