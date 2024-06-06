# ---------------------------------------------------------------------
# SQL
# ---------------------------------------------------------------------
resource "google_sql_database" "TerraFailSQL_database" {
  name     = "TerraFailSQL_database"
  instance = google_sql_database_instance.TerraFailSQL_instance.name
}

resource "google_sql_database_instance" "TerraFailSQL_instance" {
  name             = "TerraFailSQL_instance"
  region           = "us-east1"
  database_version = "SQLSERVER_2017_EXPRESS"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks {
        value = "*"
      }
      ipv4_enabled = true
      require_ssl  = false
    }
    backup_configuration {
      enabled                        = false
      point_in_time_recovery_enabled = false
    }
  }
}
