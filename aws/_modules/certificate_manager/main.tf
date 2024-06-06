

# ---------------------------------------------------------------------
# ACM
# ---------------------------------------------------------------------
resource "aws_acm_certificate" "TerraFailCertificate" {
  domain_name       = "thisisthedarkside.com"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "TerraFailCertificate_validator" {
  certificate_arn         = aws_acm_certificate.TerraFailCertificate.arn
}