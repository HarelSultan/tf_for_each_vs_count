terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.common_tags
  }
}


resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = merge(
    var.common_tags,
    {
      "Name" = "tf-harel-vpc"
    }
  )
}

resource "aws_internet_gateway" "tf-harel-igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.common_tags,
    {
      "Name" = "tf-harel-igw"
    }
  )
}

resource "aws_subnet" "subnet" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    { "Name" = "harel-instance-${count.index}" }
  )
}

resource "aws_security_group" "tf-harel-sg" {
  name        = "tf-harel-sg"
  description = "Security group allowing http/https/ssh inbound traffic all all outbound traffic"
  vpc_id      = aws_vpc.this.id

  # Allow SSH inbound
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["46.121.182.216/32"]
  }

  # Allow HTTP/HTTPS inbound
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

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { "Name" = "tf-harel" })
}



resource "aws_instance" "app_instances" {
  count                  = length(var.instances)
  ami                    = "ami-0f844a9675b22ea32"
  instance_type          = "t3a.micro"
  subnet_id              = count.index > 1 ? aws_subnet.subnet[0].id : aws_subnet.subnet[1].id
  key_name               = "AWS-Harel"
  vpc_security_group_ids = [aws_security_group.tf-harel-sg.id]

  tags = merge(
    var.common_tags,
    { "Name" = "tf-harel-${count.index}" }
  )

}
