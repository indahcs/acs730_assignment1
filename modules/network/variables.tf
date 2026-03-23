variable "default_tags" {
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}
variable "vpc_cidr" {
    type = string
    description = "VPC CIDR Block"
}
variable "public_subnet_cidrs" {
    type = list(string)
    description = "Public Subnet CIDRs"
}
variable "private_subnet_cidrs" {
    type = list(string)
    description = "Private Subnet CIDRs"
}
variable "enable_nat" {
  type = bool
  description = "Whether to create NAT Gateway for private subnets"
}
variable "env" {
    type = string
    description = "Environment name"
}
variable "prefix" {
  type        = string
  description = "Naming prefix"
}