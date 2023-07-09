terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "kxs-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "eu-west-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "kxs-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  # Configuration options
  region     = "eu-west-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
