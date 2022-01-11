# ----------------------------------
# Terraform configuration
# ----------------------------------

terraform {
  # Stores the tfstate on Amazon S3
  backend "s3" {
    bucket = "YOURE-S3-BUCKET-NAME"
    region  = "ap-northeast-1"
    key     = "ec2_web/terraform.tfstate"
    encrypt = true
  }
}
