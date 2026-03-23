locals {
  bastion_user_data = var.install_mysql_client ? (<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y mysql
  EOF
  ) : null
}

# Security Groups - Least Privilege

# --- Bastion Host Security Group ---
# only if deploy_bastion is true
resource "aws_security_group" "bastion_sg" {
    count = var.deploy_bastion ? 1 : 0
    name = "${var.env}-bastion-sg"
    description = "Security group for bastion host, Allows SSH access from admin only"
    vpc_id = var.vpc_id

    ingress {
        description = "Allow SSH from admin IPs"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.allowed_ssh_cidr]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.env}-bastion-sg"
    }
}

# --- EC2 Instances Security Group ---
# Allow SSH from bastion only and HTTP from bastion for nonprod 
resource "aws_security_group" "vm_sg" {
    name = "${var.env}-vm-sg"
    description = "Security group for EC2 instances, Allows SSH and HTTP access from bastion host only"
    vpc_id = var.vpc_id

    ingress {
        description = "Allow SSH from bastion host"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        # if bastion is in same VPC, use SG reference 
        # if bastion is in different VPC (prod), use CIDR
        security_groups = var.deploy_bastion ? [aws_security_group.bastion_sg[0].id] : []
        cidr_blocks = var.deploy_bastion ? [] : [var.allowed_ssh_cidr]
    }

    dynamic "ingress" {
      for_each = var.install_httpd ? [1] : []
        content {
            description = "Allow HTTP from bastion host"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            security_groups = var.deploy_bastion ? [aws_security_group.bastion_sg[0].id] : []
            cidr_blocks     = var.deploy_bastion ? [] : [var.allowed_ssh_cidr]
        }
    }

    dynamic "ingress" {
      for_each = var.install_mysql_client ? [1] : []
        content {
            description = "Allow MySQL from bastion host"
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            cidr_blocks = [var.allow_mysql_cidr]
        }
    }

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.env}-vm-sg"
    }
}

# --- Bastion Host ---
resource "aws_instance" "bastion" {
    count = var.deploy_bastion ? 1 : 0
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.public_subnet_cidrs[1] # Deploy bastion in the first second subnet
    key_name = var.key_name
    security_groups = [aws_security_group.bastion_sg[0].id]
    associate_public_ip_address = true
    user_data = local.bastion_user_data

    tags = {
        Name = "${var.env}-bastion"
    }
}

# --- EC2 Instances in private subnets ---
resource "aws_instance" "vm" {
    count = length(var.private_subnet_cidrs)
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.private_subnet_cidrs[count.index]
    key_name = var.key_name
    security_groups = [aws_security_group.vm_sg.id]
    associate_public_ip_address = false

    user_data = var.install_httpd ? templatefile(
        "${path.module}/templates/install_httpd.sh.tpl", {
        owner = var.owner_name
        environment  = var.env
    }) : null

    tags = {
        Name = "${var.env}-vm-${count.index + 1}"
    }
}