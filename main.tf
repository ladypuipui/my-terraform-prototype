# ----------------------------------
# Terraform configuration
# ----------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

# ----------------------------------
# Provider
# ----------------------------------

provider "aws" {
  region = "ap-northeast-1"
}


# ----------------------------------
# Type declaration
# ----------------------------------

variable "apex_domain" {
  type = string
}

variable "service_domain" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr_blocks" {
  type = string
}

variable "public_subnet_1a" {
  type = string
}
