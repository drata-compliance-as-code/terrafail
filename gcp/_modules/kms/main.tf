# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "google_kms_crypto_key" "sac_crypto_key" {
  name     = "crypto-key-example"
  key_ring = google_kms_key_ring.sac_key_ring.id
}

resource "google_kms_crypto_key_iam_binding" "sac_crypto_binding" {
  crypto_key_id = google_kms_crypto_key.sac_crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypter"
  members = [
    "user:jane@example.com",
  ]
}

resource "google_kms_crypto_key_iam_member" "sac_crypto_member" {
  crypto_key_id = google_kms_crypto_key.sac_crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypter"
  member        = "user:jane@example.com"
}

resource "google_kms_key_ring_iam_binding" "sac_key_ring_binding" {
  key_ring_id = "your-key-ring-id"
  role        = "roles/cloudkms.admin"
  members = [
    "allUsers",
  ]
}

resource "google_kms_key_ring_iam_member" "sac_key_ring_member" {
  key_ring_id = "your-key-ring-id"
  role        = "roles/cloudkms.admin"
  member      = "allUsers" # SaC Testing - Severity: Critical - set members to 'allUsers'
}

resource "google_kms_key_ring" "sac_key_ring" {
  name     = "keyring-example"
  location = "global"
}
