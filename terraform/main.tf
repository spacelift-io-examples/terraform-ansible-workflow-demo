# Configure the AWS Provider
terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


provider "spacelift" {
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220426.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_security_group" "allow_access" {
  name        = "tf-ansible-workflow-${var.spacelift_stack_id}"
  description = "Allow SSH, HTTP and HTTPS traffic"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 8000
    to_port     = 8000
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
    Name = "tf-ansible-workflow"
    SpaceliftStackID = var.spacelift_stack_id
    Ansible = "true"
  }
}


resource "aws_instance" "machine" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_access.id]

  lifecycle {
    ignore_changes = [
      # These machines are long-lived and we don't want to destroy them every
      # time there's a new Ubuntu AMI release.
      ami,
    ]
  }

  key_name = aws_key_pair.ansible-key.key_name

  tags = {
    Name = "tf-ansible-workflow-${var.spacelift_stack_id}"
    SpaceliftStackID = var.spacelift_stack_id
    Environment = "dev"
    Ansible = "true"
  }
}
