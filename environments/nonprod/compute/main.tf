provider "aws" {
  region = "us-east-1"
}

# Read the nonprod network state to get subnet and VPC IDs
data "terraform_remote_state" "aws_network" {
  backend = "s3"
  config = {
    bucket = "icstyoningrum-acs730-tfstate"
    key    = "nonprod/network/terraform.tfstate"
    region = "us-east-1"
  }
}

module "aws_compute" {
  source = "../../../modules/compute"

  env = "nonprod"
  vpc_id               = data.terraform_remote_state.aws_network.outputs.vpc_id
  private_subnet_cidrs = data.terraform_remote_state.aws_network.outputs.private_subnet_ids
  public_subnet_cidrs  = data.terraform_remote_state.aws_network.outputs.public_subnet_ids
  ami_id               = "ami-0c02fb55956c7d316"
  key_name             = "acs730-keypair"
  allowed_ssh_cidr     = "0.0.0.0/0"
  deploy_bastion       = true
  install_httpd        = true
  install_mysql_client = true

  owner_name = "Indah Cahyani Styoningrum"
}