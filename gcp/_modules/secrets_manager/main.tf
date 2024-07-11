# ---------------------------------------------------------------------
# SecretsManager
# ---------------------------------------------------------------------
resource "google_secret_manager_secret" "TerraFailSecretManager" {
  secret_id = "TerraFailSecretManager_secret"
  rotation {
  }
  replication {
    user_managed {
      replicas {
        location = "us-east1"
      }
    }
  }

}

resource "google_secret_manager_secret_iam_binding" "TerraFailSecretManager_iam_binding" {
  project   = google_secret_manager_secret.TerraFailSecretManager.project
  secret_id = google_secret_manager_secret.TerraFailSecretManager.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "user@terrafail.com",
  ]
}

resource "google_secret_manager_secret_iam_member" "TerraFailSecretManager_iam_member" {
  project   = google_secret_manager_secret.TerraFailSecretManager.project
  secret_id = google_secret_manager_secret.TerraFailSecretManager.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "allUsers"
}
