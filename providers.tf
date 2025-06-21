terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
    random = {
      source  = "hashicorp/random"   # ✅ FIXED
      version = "3.1.0"
    }
  }
}  # ✅ CLOSED terraform block


provider "aws" {
  region = "eu-central-1"
}
