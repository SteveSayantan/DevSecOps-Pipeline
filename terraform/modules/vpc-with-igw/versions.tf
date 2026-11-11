terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.92" # specifying minimum version (using >=) instead of maximum version (using ~>) for reusability
    }
  }
}