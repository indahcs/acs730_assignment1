# where to save the state file for prod compute 

terraform {
  backend "s3" {
    bucket = "icstyoningrum-acs730-tfstate"
    key = "prod/compute/terraform.tfstate"
    region = "us-east-1"
  }
}