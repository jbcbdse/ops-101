terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket = "terraform-state-123456789012-us-east-1-an"
    key    = "ops-101/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
