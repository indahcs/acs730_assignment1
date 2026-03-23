# call the module and pass in the actual values

provider "aws" {
  region = "us-east-1"
}

module "aws_network" {
  source = "../../../modules/network"
  env = "nonprod"
  vpc_cidr = "10.1.0.0/16"

  public_subnet_cidrs = [ 
    "10.1.1.0/24", # us-east-1b - NAT GW
    "10.1.2.0/24"  # us-east-1c - Bastion Host
 ]

 private_subnet_cidrs = [ 
    "10.1.3.0/24", # us-east-1b - VM1
    "10.1.4.0/24"  # us-east-1c - VM2
  ]

  availability_zones = [ 
    "us-east-1b",
    "us-east-1c"
  ]

  enable_igw = true
  enable_nat = true
}