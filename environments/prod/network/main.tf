provider "aws" {
  region = "us-east-1"
}

module "aws_network" {
  source = "../../../modules/network"
    env = "prod"
    vpc_cidr = "10.100.0.0/16" 
    public_subnet_cidrs = []
    private_subnet_cidrs = [
        "10.100.3.0/24", # us-east-1b - VM1
        "10.100.4.0/24" # us-east-1c - VM2
    ]

    availability_zones = [
        "us-east-1b", 
        "us-east-1c"
    ]
    
    enable_igw = false 
    enable_nat = false
}