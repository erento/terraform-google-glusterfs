provider "google" {
  project = "${var.project}"
  region  = "${var.google_region}"
  version = "~> 1.9"
}

data "google_client_config" "current" {}
