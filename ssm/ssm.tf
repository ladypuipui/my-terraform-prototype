# ----------------------------------
# ssm for ROLE_NAME
# ----------------------------------

resource "aws_iam_instance_profile" "ec2-ssm-profile" {
  name = "${var.service_domain}-ec2-ssm-profile"
  role = aws_iam_role.ec2-ssm-iam-role.name
}

resource "aws_iam_role" "ec2-ssm-iam-role" {
  name        = "${var.service_domain}-ec2-ssm-role"
  description = "ssm role for bastion ec2 instance"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : {
        "Effect" : "Allow",
        "Principal" : { "Service" : "ec2.amazonaws.com" },
        "Action" : "sts:AssumeRole"
      }
  })
  tags = {
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ec2-ssm-policy" {
  role       = aws_iam_role.ec2-ssm-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

output "aws_iam_instance_profile" {
  value = aws_iam_instance_profile.ec2-ssm-profile.id
}
