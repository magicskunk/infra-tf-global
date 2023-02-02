## list all resources
# terraform state list

## remove that resource you don't want to destroy
## you can add more to be excluded if required
# terraform state rm <resource_to_be_deleted>

## destroy the whole stack except above excluded resource(s)
# terraform destroy
resource "aws_route53_zone" "main" {
  name = var.primary_domain

  # To keep the same name servers
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "main_ns" {
  allow_overwrite = true
  name            = var.primary_domain
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.main.zone_id

  records = [
    aws_route53_zone.main.name_servers[0],
    aws_route53_zone.main.name_servers[1],
    aws_route53_zone.main.name_servers[2],
    aws_route53_zone.main.name_servers[3],
  ]

  lifecycle {
    prevent_destroy = true
  }
}
