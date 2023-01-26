resource "aws_route53_zone" "main" {
  name = var.primary_domain
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
}
