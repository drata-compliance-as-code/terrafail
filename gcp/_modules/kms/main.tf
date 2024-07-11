# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "google_kms_crypto_key" "TerraFailKMS" {
  name     = "TerraFailKMS"
  key_ring = google_kms_key_ring.TerraFailKMS_ring.id
}

resource "google_kms_crypto_key_iam_binding" "TerraFailKMS_iam_binding" {
  crypto_key_id = google_kms_crypto_key.TerraFailKMS.id
  role          = "roles/cloudkms.cryptoKeyEncrypter"
  members = [
    "user@terrafail.com",
  ]
}

resource "google_kms_crypto_key_iam_member" "TerraFailKMS_iam_member" {
  crypto_key_id = google_kms_crypto_key.TerraFailKMS.id
  role          = "roles/cloudkms.cryptoKeyEncrypter"
  member        = "user:jane@example.com"
}

resource "google_kms_key_ring_iam_binding" "TerraFailKMS_ring_iam_binding" {
  key_ring_id = "TerraFailKMS_ring_iam_binding"
  role        = "roles/cloudkms.admin"
  members = [
    "user@terrafail.com",
  ]
}

resource "google_kms_key_ring_iam_member" "TerraFailKMS_ring_iam_member" {
  key_ring_id = "TerraFailKMS_ring_iam_member"
  role        = "roles/cloudkms.admin"
  member      = "allUsers"
}

resource "google_kms_key_ring" "TerraFailKMS_ring" {
  name     = "TerraFailKMS_ring"
  location = "global"
}
