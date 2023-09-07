terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      project = "ssmtest"
      owner   = "pieter.vincken@ordina.be"
    }
  }
}

locals {
  name   = "ssmtest"
  region = "eu-west-1"
}
