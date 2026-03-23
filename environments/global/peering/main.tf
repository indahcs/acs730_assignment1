provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "nonprod_network" {
  backend = "s3"
  config = {
    bucket = "icstyoningrum-acs730-tfstate"
    key = "nonprod/network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "prod_network" {
  backend = "s3"
  config = {
    bucket = "icstyoningrum-acs730-tfstate"
    key = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}

module "peering" {
  source = "../../../modules/peering"

  nonprod_vpc_id = data.terraform_remote_state.nonprod_network.outputs.vpc_id
  prod_vpc_id    = data.terraform_remote_state.prod_network.outputs.vpc_id

  nonprod_vpc_cidr = data.terraform_remote_state.nonprod_network.outputs.vpc_cidr
  prod_vpc_cidr    = data.terraform_remote_state.prod_network.outputs.vpc_cidr

  nonprod_vpc_route_table_id = data.terraform_remote_state.nonprod_network.outputs.private_route_table_id
  prod_vpc_route_table_id    = data.terraform_remote_state.prod_network.outputs.private_route_table_id
}