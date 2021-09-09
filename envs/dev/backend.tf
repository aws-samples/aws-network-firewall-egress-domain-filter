terraform {
  backend "s3" {
    bucket = "my-terraform-backend"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}