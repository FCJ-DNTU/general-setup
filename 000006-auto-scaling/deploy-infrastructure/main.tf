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

# Setup VPC
resource "aws_vpc" "aslab" {
  cidr_block = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = local.network_root_name
    Type = "VPC"
    Author = local.author
  }
}

## Setup subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.aslab.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${local.region}a"
  tags = {
    Name = "${local.network_root_name}_public_subnet_1"
    Type = "Subnet"
    Author = local.author
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.aslab.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${local.region}a"
  tags = {
    Name = "${local.network_root_name}_private_subnet_1"
    Type = "Subnet"
    Author = local.author
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.aslab.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${local.region}b"
  tags = {
    Name = "${local.network_root_name}_public_subnet_2"
    Type = "Subnet"
    Author = local.author
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.aslab.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "${local.region}b"
  tags = {
    Name = "${local.network_root_name}_private_subnet_2"
    Type = "Subnet"
    Author = local.author
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id = aws_vpc.aslab.id
  cidr_block = "10.0.5.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${local.region}c"
  tags = {
    Name = "${local.network_root_name}_public_subnet_3"
    Type = "Subnet"
    Author = local.author
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id = aws_vpc.aslab.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "${local.region}c"
  tags = {
    Name = "${local.network_root_name}_private_subnet_3"
    Type = "Subnet"
    Author = local.author
  }
}

## Setup internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aslab.id
  tags = {
    Name = "${local.network_root_name}_igw"
    Type = "Internet_Gateway"
    Author = local.author
  }
}

## Setup route table and its associations
resource "aws_route_table" "public_route_table_1" {
  vpc_id = aws_vpc.aslab.id

  # Internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # Local
  route {
    cidr_block = local.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${local.network_root_name}_public_route_table_1"
    Type = "Route_Table"
    Author = local.author
  }
}

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.aslab.id

  # Local
  route {
    cidr_block = local.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "${local.network_root_name}_private_route_table_1"
    Type = "Route_Table"
    Author = local.author
  }
}

resource "aws_route_table_association" "public_association_1" {
  route_table_id = aws_route_table.public_route_table_1.id
  subnet_id = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "public_association_2" {
  route_table_id = aws_route_table.public_route_table_1.id
  subnet_id = aws_subnet.public_subnet_2.id
}

resource "aws_route_table_association" "public_association_3" {
  route_table_id = aws_route_table.public_route_table_1.id
  subnet_id = aws_subnet.public_subnet_3.id
}

resource "aws_route_table_association" "private_association_1" {
  route_table_id = aws_route_table.private_route_table_1.id
  subnet_id = aws_subnet.private_subnet_1.id
}

resource "aws_route_table_association" "private_association_2" {
  route_table_id = aws_route_table.private_route_table_1.id
  subnet_id = aws_subnet.private_subnet_2.id
}

resource "aws_route_table_association" "private_association_3" {
  route_table_id = aws_route_table.private_route_table_1.id
  subnet_id = aws_subnet.private_subnet_3.id
}

# Setup Security Group
resource "aws_security_group" "public_sg" {
  description = "Allow access to server"
  vpc_id = aws_vpc.aslab.id
  tags = {
    Name = "${local.network_root_name}_public_sg"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_sg_inbound_1" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  # Port
  from_port = 22
  to_port = 22
  # Protocol
  ip_protocol = "tcp"
  tags = {
    Name = "${local.network_root_name}_public_sg_inbound_1"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_sg_inbound_2" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  # Port
  from_port = 80
  to_port = 80
  # Protocol
  ip_protocol = "tcp"
  tags = {
    Name = "${local.network_root_name}_public_sg_inbound_2"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_sg_inbound_3" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  # Port
  from_port = 443
  to_port = 443
  # Protocol
  ip_protocol = "tcp"
  tags = {
    Name = "${local.network_root_name}_public_sg_inbound_3"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_sg_inbound_4" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  # Port
  from_port = 5000
  to_port = 5000
  # Protocol
  ip_protocol = "tcp"
  tags = {
    Name = "${local.network_root_name}_public_sg_inbound_4"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_vpc_security_group_egress_rule" "public_sg_outbound" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
  tags = {
    Name = "${local.network_root_name}_public_sg_outbound_1"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_security_group" "db_sg" {
  description = "Allow server access to database server"
  vpc_id = aws_vpc.aslab.id
  tags = {
    Name = "${local.network_root_name}_db_sg"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_sg_inbound" {
  security_group_id = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.public_sg.id
  # Port
  from_port = 3306
  to_port = 3306
  # Protocol
  ip_protocol = "tcp"
  tags = {
    Name = "${local.network_root_name}_db_sg_inbound"
    Type = "Security_Group"
    Author = local.author
  }
}

resource "aws_vpc_security_group_egress_rule" "private_terra_sg_outbound" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
  tags = {
    Name = "${local.network_root_name}_db_sg_outbound"
    Type = "Security_Group"
    Author = local.author
  }
}

# Setup EC2 Instance
resource "aws_instance" "my_server" {
  # Use Amazon Linux 2023
  ami = "ami-0aa097a5c0d31430a"
  instance_type = "t2.micro"
  # Change your key-pair here
  key_name = local.key_name
  subnet_id = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [
    aws_security_group.public_sg.id
  ]

  tags = {
    Name = "${local.compute_root_name}_my_server"
    Type = "EC2"
    Author = local.author
  }
}

# Setup RDS
## Setup subnet group
resource "aws_db_subnet_group" "subnet_group" {
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
  ]

  tags = {
    Name = "${local.compute_root_name}_private_subnet_group"
    Type = "RDS_Subnet_Group"
    Author = local.author
  }
}

## Setup Multi-AZ DB Instance
resource "aws_db_instance" "rds" {
  identifier = "${lower(local.compute_root_name)}-db-instance"
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.m5.large"
  allocated_storage = 20
  multi_az = true
  storage_type = "gp2"
  username = local.db_username
  password = local.db_password
  db_name = local.db_name
  port = 3306
  publicly_accessible = false
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.db_sg.id
  ]
  
  tags = {
    Name = "${local.compute_root_name}_database_server"
    Type = "RDS_Instance"
    DatabaseEngine = "MySQL"
    Author = local.author
  }
}

# Setup Load Balancer
resource "aws_lb" "load_balancer" {
  load_balancer_type = "application"
  internal = false
  security_groups = [
    aws_security_group.public_sg.id
  ]
  ip_address_type = "ipv4"
  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id
  ]

  tags = {
    Name = "${local.compute_root_name}_load_balancer"
    Type = "Load_Balancer"
    Author = local.author
  }
}

# Setup target group
resource "aws_lb_target_group" "target_group" {
  port = 5000
  protocol = "HTTP"
  vpc_id = aws_vpc.aslab.id
  target_type = "instance"

  tags = {
    Name = "${local.compute_root_name}_target_group"
    Type = "Target_Group"
    Author = local.author
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id = aws_instance.my_server.id
  port = 5000
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  tags = {
    Name = "${local.compute_root_name}_listener"
    Type = "LB_Listener"
    Author = local.author
  }
}

# Output
output "vpc_id" {
  value = aws_vpc.aslab.id
}

output "vpc_arn" {
  value = aws_vpc.aslab.arn
}

output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "public_subnet_3_id" {
  value = aws_subnet.public_subnet_3.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "private_subnet_3_id" {
  value = aws_subnet.private_subnet_3.id
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "public_sg_arn" {
  value = aws_security_group.public_sg.arn
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "db_sg_arn" {
  value = aws_security_group.db_sg.arn
}

output "server_instance_id" {
  value = aws_instance.my_server.id
}

output "server_arn" {
  value = aws_instance.my_server.arn
}

output "server_dns" {
  value = aws_instance.my_server.public_dns
}

output "database_id" {
  value = aws_db_instance.rds.id
}

output "database_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "database_arn" {
  value = aws_db_instance.rds.arn
}

output "load_balancer_id" {
  value = aws_lb.load_balancer.id
}

output "load_balancer_arn" {
  value = aws_lb.load_balancer.arn
}

output "target_group_id" {
  value = aws_lb_target_group.target_group.id
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}