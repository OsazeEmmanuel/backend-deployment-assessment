terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "startuptech_vpc" {

  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "startuptech-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = "10.0.1.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = "10.0.2.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}
resource "aws_subnet" "private_subnet_1" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = "10.0.3.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {

  vpc_id = aws_vpc.startuptech_vpc.id

  cidr_block = "10.0.4.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.startuptech_vpc.id

  tags = {
    Name = "startuptech-igw"
  }
}

resource "aws_eip" "nat_eip" {

  domain = "vpc"

  tags = {
    Name = "startuptech-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat_eip.id

  subnet_id = aws_subnet.public_subnet_1.id

  tags = {
    Name = "startuptech-nat"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.startuptech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.startuptech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "alb_sg" {

  name        = "alb-security-group"
  description = "Allow HTTP and HTTPS"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "bastion_sg" {

  name        = "bastion-security-group"
  description = "Allow SSH from my IP"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "backend_sg" {

  name        = "backend-security-group"
  description = "Backend access"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-sg"
  }
}

resource "aws_security_group" "mongodb_sg" {

  name        = "mongodb-security-group"
  description = "MongoDB access"
  vpc_id      = aws_vpc.startuptech_vpc.id

  ingress {
    description     = "MongoDB from Backend"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongodb-sg"
  }
}


data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_eip" "bastion_eip" {

  domain = "vpc"

  tags = {
    Name = "bastion-eip"
  }
}

resource "aws_instance" "bastion" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.public_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  key_name = var.key_name

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_eip_association" "bastion_eip_assoc" {

  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}

resource "aws_instance" "backend" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.private_subnet_1.id

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]

  key_name = var.key_name

  user_data = file("${path.module}/user_data/backend_setup.sh")

  tags = {
    Name = "backend-server"
  }
}

resource "aws_instance" "mongodb" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.private_subnet_2.id

  vpc_security_group_ids = [
    aws_security_group.mongodb_sg.id
  ]

  key_name = var.key_name

  user_data = file("${path.module}/user_data/mongodb_setup.sh")

  tags = {
    Name = "mongodb-server"
  }
}

resource "aws_lb_target_group" "backend_tg" {

  name     = "backend-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.startuptech_vpc.id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "8080"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "backend-target-group"
  }
}

resource "aws_lb_target_group_attachment" "backend_attachment" {

  target_group_arn = aws_lb_target_group.backend_tg.arn

  target_id = aws_instance.backend.id

  port = 8080
}

resource "aws_lb" "startuptech_alb" {

  name               = "startuptech-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "startuptech-alb"
  }
}

resource "aws_lb_listener" "http_listener" {

  load_balancer_arn = aws_lb.startuptech_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
