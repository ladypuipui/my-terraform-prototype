# ----------------------------------
# hostzone for ROLE_NAME
# ----------------------------------

resource "aws_route53_zone" "public" {
  name          = var.apex_domain
  comment       = "Managed by Terraform"
  force_destroy = false
}

output "public" {
  value = "aws_route53_zone.public.id"
}
