# ---------------------------------------------------------------------
# SQL
# ---------------------------------------------------------------------
resource "google_sql_database" "sac_sql_db" {
  name     = "test-database"
  instance = google_sql_database_instance.sac_sql_db_instance.name
}

resource "google_sql_database_instance" "sac_sql_db_instance" {
  name             = "test-instance"
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
