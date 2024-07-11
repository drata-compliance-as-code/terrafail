# ---------------------------------------------------------------------
# App Engine
# ---------------------------------------------------------------------
resource "google_app_engine_application" "TerraFailAppEngine" {
  location_id = "us-east1"
  project     = "terrafail"
}

resource "google_app_engine_flexible_app_version" "TerraFailAppEngine_version_flex" {
  project    = "terrafail"
  version_id = "v2"
  service    = google_app_engine_application.TerraFailAppEngine.id
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
    security_level = "SECURE_ALWAYS"
    script         = "path/to/script.py"
  }
  handlers {
    security_level = "SECURE_DEFAULT"
  }
  handlers {
    security_level = "SECURE_ALWAYS"
  }
}

resource "google_app_engine_standard_app_version" "TerraFailAppEngine_version_standard" {
  project    = "terrafail"
  version_id = "v1"
  service    = google_app_engine_application.TerraFailAppEngine.id
  runtime    = "java21"
  entrypoint {
    shell = "python ./app.py"
  }
  handlers {
    security_level = "SECURE_ALWAYS"
  }
  deployment {
    zip {
      source_url = "https://test.sample.com"
    }
  }
}

resource "google_app_engine_firewall_rule" "TerraFailAppEngine_firewall_rule" {
  project      = "terrafail"
  action       = "ALLOW"
  source_range = "*"
}
