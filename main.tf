resource "google_compute_instance" "default" {
  count        = "${var.cluster_size}"
  name         = "${var.server_prefix}-${count.index}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region}-${var.zones[count.index]}"

  can_ip_forward = true

  tags = "${var.tags}"

  boot_disk {
    device_name = "boot"

    initialize_params {
      image = "${var.image}"
      size  = "${var.boot_disk_size}"
      type  = "pd-standard"
    }
  }

  attached_disk = [
    {
      device_name = "gluster"
      source      = "${element(formatlist("%v", google_compute_disk.default.*.name), count.index)}"
    },
  ]

  network_interface {
    subnetwork = "${var.subnetwork}"
    address    = "${cidrhost(var.subnet_mask, -count.index - var.ip_offset)}" # This takes last 3 IPs of the subnet (they are usually free - if not ip_offset can be uset to shift ips)

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

  depends_on = ["google_compute_disk.default", "google_compute_subnetwork.default"]
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
    cluster_size    = "${var.cluster_size}"
    server_prefix   = "${var.server_prefix}"
    volume_names    = "${join(" ",var.volume_names)}"
    replicas_number = "${var.replicas_number}"
  }
}

data "template_file" "endpoint" {
  count    = "${var.cluster_size}"
  template = "${file("${path.module}/files/endpoint.json.tpl")}"

  vars {
    ip = "${element(google_compute_instance.default.*.network_interface.0.address, count.index)}"
  }
}

data "template_file" "kubernetes_endpoints" {
  template = "${file("${path.module}/files/kubernetes_endpoints.json.tpl")}"

  vars {
    endpoints                = "${join(",\n    ", data.template_file.endpoint.*.rendered)}"
    kubernetes_endpoint_name = "${var.kubernetes_endpoint_name}"
  }
}

resource "google_compute_subnetwork" "default" {
  name          = "${var.subnetwork}"
  ip_cidr_range = "${var.subnet_mask}"
  region        = "${var.region}"
  network       = "${var.network}"
}

resource "google_compute_firewall" "default" {
  name    = "gluster-firewall"
  network = "${var.network}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  source_tags = "${var.allowed_source_tags}"
  target_tags = "${var.tags}"
}

resource "null_resource" "export_rendered_template" {
  provisioner "local-exec" {
    command = "cat > ${var.kubernetes_endpoint_file_path} <<EOL\n${data.template_file.kubernetes_endpoints.rendered}\nEOL"
  }

  triggers = {
    update_config = "${timestamp()}"
  }
}
