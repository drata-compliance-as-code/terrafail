
# ---------------------------------------------------------------------
# Kinesis
# ---------------------------------------------------------------------
resource "aws_kinesis_stream" "sac_kinesis_stream" {
  name             = "sac-testing-kinesis"
  shard_count      = 1
  retention_period = 24 # SaC Testing - Severity: High - set retention_period to default (0 or 24)
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  encryption_type = "NONE" # SaC Testing - Severity: Moderate - set tags to undefined
  #kms_key_id = aws_kms_key.kinesis_key.id  # SaC Testing - Severity: Moderate - set kms_key_id to undefined
  # SaC Testing - Severity: Moderate - set tags to undefined
  # tags = {
  #   Environment = "test"
  # }
}
