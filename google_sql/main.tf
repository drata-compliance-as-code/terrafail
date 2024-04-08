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
  database_version = "SQLSERVER_2017_EXPRESS" # condition: SaC Testing - Severity: Moderate - set database_version == to 'postgres'
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks {
        value = "*" # SaC Testing - Severity: High - set value to '*'
      }
      ipv4_enabled = true  # SaC Testing - Severity: Moderate - set ipv4_enabled to True
      require_ssl  = true
    }
    backup_configuration {
      enabled                        = false # SaC Testing - Severity: Moderate - set enabled to False
      point_in_time_recovery_enabled = false # SaC Testing - Severity: Moderate - set point_in_time_recovery_enabled to False
    }
  }
}
