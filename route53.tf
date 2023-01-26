resource "aws_route53_zone" "primary" {
  name = var.primary_domain
}

resource "aws_route53_record" "primary_ns" {
  allow_overwrite = true
  name            = var.primary_domain
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.primary.zone_id

  records = [
    aws_route53_zone.primary.name_servers[0],
    aws_route53_zone.primary.name_servers[1],
    aws_route53_zone.primary.name_servers[2],
    aws_route53_zone.primary.name_servers[3],
  ]
}
