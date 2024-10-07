locals {
  region = "ap-southeast-1"
  author = "FCJ-DNTU"
  network_root_name = "AutoScaling-Lab"
  compute_root_name = "FCJ-Management"
  vpc_cidr = "10.0.0.0/16"
  db_username = "fcjdntu"
  db_password = "letmein12345"
  db_name = "awsfcjuser"
  key_name = "aptopus-ai"

  # Replace these values
  target_group_arn = "arn:aws:elasticloadbalancing:ap-southeast-1:992382427232:targetgroup/tf-20241004062442789300000003/cf1207135a00d4f0"
  public_sg_id = "sg-08e6aa0564f1eb39d"
  server_instance_id = "i-03ad08b6a027db372"
  public_subnet_1_id = "subnet-085e989ca78672e7a"
  public_subnet_2_id = "subnet-060143b9d52780361"
  public_subnet_3_id = "subnet-067cc2fee66634e8f"
  private_subnet_1_id = "subnet-0704241e310e496e8"
  private_subnet_2_id = "subnet-081d4d8c8f8419411"
  private_subnet_3_id = "subnet-026cc71a53b30d4e7"
}

# Setup provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.region
}

# Setup AMI
resource "aws_ami_from_instance" "instance_ami" {
  name = "${local.compute_root_name}-ami"
  source_instance_id = local.server_instance_id

  tags = {
    Name = "${local.compute_root_name}-ami"
    Type = "Launch_Template"
    Author = local.author
  }
}

# Setup launch template
resource "aws_launch_template" "my_launch_template" {
  name = "${local.compute_root_name}-template"
  image_id = aws_ami_from_instance.instance_ami.id
  instance_type = "t2.micro"
  key_name = local.key_name

  vpc_security_group_ids = [
    local.public_sg_id
  ]

  tags = {
    Name = "${local.compute_root_name}-launch-template"
    Type = "Launch_Template"
    Author = local.author
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${local.compute_root_name}-asg"
  desired_capacity = 1
  min_size = 1
  max_size = 3

  target_group_arns = [
    local.target_group_arn
  ]

  vpc_zone_identifier = [
    local.public_subnet_1_id,
    local.public_subnet_2_id,
    local.public_subnet_3_id
  ]

  launch_template {
    id = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  health_check_type = "EC2"
  health_check_grace_period = 300
}