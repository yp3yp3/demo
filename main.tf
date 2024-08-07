terraform {
  backend "s3" {
     bucket         = "tf-state-test-987234" # REPLACE WITH YOUR BUCKET NAME
     key            = "example/staging/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "terraform-state-locking"
     encrypt        = true
   }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "instances" {
  name = "instances_sg_${var.environment_name}"
}
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.environment_name == "production" ? "t2.micro" : "t2.small"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.instances.id]
   user_data       = <<-EOF
              #!/bin/bash
              echo '<html><body style="background-color:green;">Hello, World ${var.environment_name}</body></html>' > index.html
              python3 -m http.server 80 &
              EOF
  tags = {
    Name = "${var.environment_name} instance"
  }
}
locals {
  subdomain   = var.environment_name == "production" ? "" : "${var.environment_name}."
}
data "aws_route53_zone" "primary" {
  name  = var.domain
  }
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${local.subdomain}${var.domain}"
  type    = "A"
  records = [aws_instance.example.public_ip]
  ttl     = "300" 
  
}