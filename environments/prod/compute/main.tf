provider "aws" {
    region = "us-east-1"
}

data "terraform_remote_state" "aws_network" {
    backend = "s3"
    config = {
        bucket = "icstyoningrum-acs730-tfstate"
        key = "prod/network/terraform.tfstate"
        region = "us-east-1"
    }
}

# Get the nonprod bastion SG id, so it could allow SSH via peering connection
# data "terraform_remote_state" "nonprod_compute" {
#     backend = "s3"
#     config = {
#         bucket = "icstyoningrum-acs730-tfstate"
#         key = "nonprod/compute/terraform.tfstate"
#         region = "us-east-1"
#     }
# }

module "aws_compute" {
  source = "../../../modules/compute"

  env = "prod"
  vpc_id               = data.terraform_remote_state.aws_network.outputs.vpc_id
  private_subnet_cidrs = data.terraform_remote_state.aws_network.outputs.private_subnet_ids
  public_subnet_cidrs  = []
  ami_id               = "ami-0c02fb55956c7d316"
  key_name             = "acs730-keypair"
  allowed_ssh_cidr     = "10.1.0.0/16" # only nonprod VPC can reach prod via peering connection
  deploy_bastion       = false
  install_httpd        = false
  install_mysql_client = true

  allow_mysql_cidr = "10.1.0.0/16" # only nonprod VPC can reach prod via peering connection

  # get the nonprod bastion SG id, so it could allow SSH via peering connection
  # bastion_sg_id = data.terraform_remote_state.nonprod_compute.outputs.bastion_sg_id
}