

# ---------------------------------------------------------------------
# ACM
# ---------------------------------------------------------------------
resource "aws_acm_certificate" "TerraFailCertificate" {
  # Drata: Set [aws_acm_certificate.tags] to ensure that organization-wide tagging conventions are followed.
  domain_name       = "thisisthedarkside.com"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "TerraFailCertificate_validator" {
  certificate_arn         = aws_acm_certificate.TerraFailCertificate.arn
}