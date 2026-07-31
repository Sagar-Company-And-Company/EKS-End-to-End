terraform {

  required_version = ">= 1.5"

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 6.0"
    }
  }

  backend "s3" {

    bucket         = "bakend-s3-for-eks"

    key            = "eks/dev/terraform.tfstate"

    region         = "us-east-1"

    encrypt        = true

    use_lockfile   = true
  }
}

provider "aws" {

  region = var.region
}
