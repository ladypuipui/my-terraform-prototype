# ----------------------------------
# ec2 for ROLE_NAME
# ----------------------------------

data "aws_ssm_parameter" "amazonlinux2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  vpc      = true
}

resource "aws_instance" "this" {
  ami           = data.aws_ssm_parameter.amazonlinux2.value
  instance_type = "t3.micro"


  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.web_sg
  ]

  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_1a
  associate_public_ip_address = "true"
  iam_instance_profile        = data.terraform_remote_state.ssm.outputs.aws_iam_instance_profile
  tags = {
    Name    = "${var.service_domain}-wiki"
    Project = var.project
    Env     = var.environment
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 15
  }
}
