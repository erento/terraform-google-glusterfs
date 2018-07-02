output disks {
  value = "${google_compute_disk.default.*.name}"
}

output static_ips {
  value = "${var.static_ips}"
}
