terraform {
  backend "gcs" {
    bucket = "test-glusterfs-tfstate-beta"
    prefix = "terraform/glusterfs"
  }
}
