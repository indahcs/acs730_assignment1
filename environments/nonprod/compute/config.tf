# where to save the state file for compute networking 

terraform {
  backend "s3" {
    bucket = "icstyoningrum-acs730-tfstate"
    key = "nonprod/compute/terraform.tfstate"
    region = "us-east-1"
  }
}