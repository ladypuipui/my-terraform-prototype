# Add data as needed

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "YOURE-S3-BUCKET-NAME"
    key    = "nw/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "ssm" {
  backend = "s3"

  config = {
    bucket = "YOURE-S3-BUCKET-NAME"
    key    = "ssm/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
