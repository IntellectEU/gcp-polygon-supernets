data "google_service_account" "polygon_sa" {
  account_id = google_service_account.polygon_sa.name
}

resource "google_service_account" "polygon_sa" {
  account_id   = "polygon-sa"
  display_name = "polygon-sa"
}

resource "google_service_account_key" "polygon_sa" {
  service_account_id = google_service_account.polygon_sa.name
}

resource "google_project_iam_binding" "polygon_sa_binding" {
  project = var.project
  role    = "roles/editor"

  members = [
    "serviceAccount:${google_service_account.polygon_sa.email}"
  ]
}

resource "local_file" "polygon_sa_key" {
  filename = "polygon-sa.json"
  content  = base64decode(google_service_account_key.polygon_sa.private_key)
}
