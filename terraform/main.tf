module "cluster" {
  source         = "./module"
  server_prefix  = "${var.server_prefix}"
  disk_prefix    = "${var.disk_prefix}"
  static_ips     = "${var.static_ips}"
  data_disk_size = "${var.data_disk_size}"
  network        = "${var.network}"
  disk_snapshot  = "${var.disk_snapshot}"
}

variable network {}
variable server_prefix {}
variable disk_prefix {}

variable static_ips {
  type = "list"
}

variable data_disk_size {}

variable disk_snapshot {
  default = ""
}
