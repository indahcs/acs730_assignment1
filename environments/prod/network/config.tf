# where to save the state file for prod networking 

terraform {
  backend "s3" {
    bucket = "icstyoningrum-acs730-tfstate"
    key = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}