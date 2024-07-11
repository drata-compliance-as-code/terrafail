# ---------------------------------------------------------------------
# Big Query
# ---------------------------------------------------------------------
resource "google_bigquery_dataset" "TerraFailBigQuery_dataset" {
  dataset_id = "TerraFailBigQuery_dataset"
  location   = "US-EAST1"
  project    = "terrafail"

  access {
    special_group = "allUseres"
  }
}

resource "google_bigquery_dataset_iam_binding" "TerraFailBigQuery_iam_binding" {
  dataset_id = google_bigquery_dataset.TerraFailBigQuery_dataset.dataset_id
  role       = "roles/bigquery.dataViewer"
  members = [
    "user@terrafail.com",
  ]
}

resource "google_bigquery_dataset_iam_member" "TerraFailBigQuery_iam_member" {
  dataset_id = google_bigquery_dataset.TerraFailBigQuery_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "user@terrafail.com"
}

resource "google_bigquery_table" "TerraFailBigQuery_table" {
  dataset_id = google_bigquery_dataset.TerraFailBigQuery_dataset.dataset_id
  table_id   = "bigQ"
  time_partitioning {
    type = "DAY"
  }
}

resource "google_bigquery_table_iam_binding" "TerraFailBigQuery_table_iam_binding" {
  dataset_id = google_bigquery_table.TerraFailBigQuery_table.dataset_id
  table_id   = google_bigquery_table.TerraFailBigQuery_table.table_id
  role       = "roles/bigquery.dataOwner"
  members = [
    "user@terrafail.com",
  ]
}

resource "google_bigquery_table_iam_member" "TerraFailBigQuery_table_iam_member" {
  dataset_id = google_bigquery_table.TerraFailBigQuery_table.dataset_id
  table_id   = google_bigquery_table.TerraFailBigQuery_table.table_id
  role       = "roles/bigquery.dataOwner"
  member     = "user@terrafail.com"
}
