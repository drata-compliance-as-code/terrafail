

# ---------------------------------------------------------------------
# ACM
# ---------------------------------------------------------------------
resource "aws_acm_certificate" "sac_acm_cert" {
  domain_name       = "thisisthedarkside.com"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "sac_cert_validator" {
  certificate_arn         = aws_acm_certificate.sac_acm_cert.arn
}