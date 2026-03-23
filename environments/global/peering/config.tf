# where to save the state file for compute networking 

terraform {
  backend "s3" {
    bucket = "icstyoningrum-acs730-tfstate"
    key = "global/peering/terraform.tfstate"
    region = "us-east-1"
  }
}