output "disks" {
  value = google_compute_disk.default.*.name
}

output "static_ips" {
  value = google_compute_instance.default.*.network_interface.0.address
}

