terraform {

  required_version = ">= 1.5"

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 6.0"
    }
  }

  backend "s3" {

    bucket         = "your-terraform-state-bucket"

    key            = "eks/dev/terraform.tfstate"

    region         = "ap-south-1"

    dynamodb_table = "terraform-lock"

    encrypt        = true
  }
}

provider "aws" {

  region = var.region
}
