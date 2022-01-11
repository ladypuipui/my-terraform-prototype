# ----------------------------------
# securitygroup for ROLE_NAME
# ----------------------------------

# web security group
resource "aws_security_group" "web_sg" {
  name        = "${var.service_domain}-igw-web-sg"
  description = "web front role security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "${var.service_domain}-web-sg"
    Project = var.project
    Env     = var.environment
  }
}

output "web_sg" {
  value = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_in_http" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_in_https" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbount_ICMP" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outband" {
  security_group_id = aws_security_group.web_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}
