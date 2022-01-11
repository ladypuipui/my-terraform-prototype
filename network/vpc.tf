# ----------------------------------
# VPC for ROLE_NAME
# ----------------------------------


resource "aws_vpc" "main" {
  cidr_block       = var.cidr_blocks
  instance_tenancy = "default"

  tags = {
    Name    = "${var.service_domain}-vpc"
    Project = "${var.project}"
    Env     = "${var.environment}"
  }
}
