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