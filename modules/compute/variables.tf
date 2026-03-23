variable "env" {
  description = "Environment name"
  type = string
}

variable "vpc_id" {
  description = "VPC ID to deploy instances into"
  type = string
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs to deploy instances into"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs to deploy instances into"
  type        = list(string)
  default = []
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string 
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type = string
}

variable "deploy_bastion" {
  description = "Whether to deploy a bastion host in the public subnet"
  type = bool
  default = false
}

variable "install_httpd" {
  description = "Whether to install Apache HTTP Server on the EC2 instances"
  type = bool
  default = false
}

variable "install_mysql_client" {
  description = "Whether to install MySQL client on the EC2 instances"
  type = bool
  default = false
}

variable "bastion_sg_id" {
  description = "Security Group ID for the bastion host"
  type = string
  default = ""
}

variable "allowed_ssh_cidr" {
  description = "ID CIDR that can SSH into the bastion"
  type = string
}

variable "owner_name" {
  description = "Name to display on the web page"
  type = string
  default = "Indah Cahyani Styoningrum"
}