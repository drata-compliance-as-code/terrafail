provider "google" {
  credentials = file("")
  project     = "tfcloud-testing"
  region      = "us-east1"
}

# ---------------------------------------------------------------------
# App Engine
# ---------------------------------------------------------------------
resource "google_app_engine_application" "sac_app_engine" {
  location_id = "us-east1"
  project     = "tfcloud-testing"
}

resource "google_app_engine_flexible_app_version" "sac_flexible_app" {
  project    = "tfcloud-testing"
  version_id = "v2"
  service    = google_app_engine_application.sac_app_engine.id
  runtime    = "java8"
  automatic_scaling {
    cool_down_period = "120s"
    cpu_utilization {
      target_utilization = 0.5
    }
  }
  liveness_check {
    path = "/"
  }
  readiness_check {
    path = "/"
  }
  api_config {
    security_level = "SECURE_DEFAULT"
    script         = "path/to/script.py"
  }
  handlers {
    security_level = "SECURE_DEFAULT"
  }
}

resource "google_app_engine_standard_app_version" "sac_standard_app" {
  project    = "tfcloud-testing"
  version_id = "v1"
  service    = google_app_engine_application.sac_app_engine.id
  runtime    = "java8"
  entrypoint {
    shell = "python ./app.py"
  }
  handlers {
    security_level = "SECURE_DEFAULT"
  }
  deployment {
    zip {
      source_url = "https://test.sample.com"
    }
  }
}

resource "google_app_engine_firewall_rule" "sac_app_firewall_rule" {
  project      = "tfcloud-testing"
  action       = "ALLOW"
  source_range = "*"
}
