# variable "default_tags" {
#   type        = map(any)
#   description = "Default tags to be applied to all AWS resources"
# }
variable "availability_zones" {
  description = "List of availability zones to deploy subnets into"
  type        = list(string)
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
variable "enable_igw" {
  type = bool
  description = "Whether to create Internet Gateway for public subnets"
  default     = false
}
variable "enable_nat" {
  type = bool
  description = "Whether to create NAT Gateway for private subnets"
  default     = false
}
variable "env" {
    type = string
    description = "Environment name"
}
# variable "prefix" {
#   type        = string
#   description = "Naming prefix"
# }