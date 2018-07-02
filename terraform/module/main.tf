resource "google_compute_instance" "default" {
  count          = "${var.cluster_size}"
  name           = "${var.server_prefix}-${count.index}"
  machine_type   = "${var.machine_type}"
  zone           = "${var.region}-${var.zones[count.index]}"
  can_ip_forward = true

  tags = "${var.tags}"

  boot_disk {
    initialize_params {
      image = "${var.image}"
      size  = "${var.boot_disk_size}"
      type  = "pd-standard"
    }
  }

  attached_disk = [
    {
      source = "${element(formatlist("%v", google_compute_disk.default.*.name), count.index)}"
    },
  ]

  network_interface {
    network = "${var.network}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    foo = "bar"
  }

  metadata_startup_script = "${element(formatlist("%v", data.template_file.provision_script.*.rendered), count.index)}"

  service_account {
    scopes = ["compute-rw", "logging-write", "monitoring-write", "storage-full"]
  }

  depends_on = ["google_compute_disk.default"]
}

resource "google_compute_disk" "default" {
  count = "${var.cluster_size}"
  name  = "${var.disk_prefix}-${count.index}"
  type  = "${var.disk_type}"
  zone  = "${var.region}-${var.zones[count.index]}"

  image    = "${var.disk_snapshot == "" ? "${var.image}" : ""}"
  size     = "${var.data_disk_size}"
  snapshot = "${var.disk_snapshot}"

  labels {
    environment = "glusterfs"
  }
}

data "template_file" "provision_script" {
  count    = "${var.cluster_size}"
  template = "${file("${path.module}/files/glusterfs_provision_server.sh")}"

  vars {
    static_ip = "${element(var.static_ips, count.index)}"
  }
}

resource "google_compute_route" "default" {
  count                  = "${var.cluster_size}"
  name                   = "ip-${var.server_prefix}-${count.index}"
  dest_range             = "${element(var.static_ips, count.index)}/32"
  network                = "${var.network}"
  next_hop_instance      = "${var.server_prefix}-${count.index}"
  next_hop_instance_zone = "${var.region}-${var.zones[count.index]}"
  priority               = 100

  depends_on = ["google_compute_instance.default"]
}
