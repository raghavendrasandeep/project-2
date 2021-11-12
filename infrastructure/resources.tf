terraform {
    # required_version = "0.12.29"
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = var.region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    token = var.aws_session_token
}


module "vpc" {
    source ="terraform-aws-modules/vpc/aws"

    name = "application-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["${var.region}a"]
    public_subnets  = ["10.0.101.0/24"]

    tags ={
        createdBy = "<%=username%>"
    }
}


resource "aws_instance" "app_vm" {
    #Amazon linux 2 AMI (HVM), SSD Volume Type
    ami                         = var.ami
    instance_type               = "t2.micro"
    subnet_id                   = module.vpc.public_subnets[0]
    vpc_security_group_ids      = [aws_security_group.vm_sg.id]
    key_name                    = "my-key-pair"
    associate_public_ip_address = false

    tags = {
        Name        = "application-vm"
        createdBy   = "Sandy"
    }
}

resource "aws_eip" "elastic_ip" {
    instance = aws_instance.app_vm.id
    vpc      = true
}


resource "aws_security_group" "vm_sg" {
  name        = "vm-security-group"
  description = "Allow incoming connections."

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # application
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
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
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}