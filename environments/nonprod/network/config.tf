# where to save the state file for nonprod networking 

terraform {
  backend "s3" {
    bucket = "icstyoningrum-acs730-tfstate"
    key = "nonprod/network/terraform.tfstate"
    region = "us-east-1"
  }
}