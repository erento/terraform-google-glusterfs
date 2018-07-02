variable project {}

variable region {
  default = "europe-west1"
}

variable zones {
  default = ["b", "c", "d"]
}

variable server_prefix {
  default = "glusterfs-server"
}

variable static_ips {
  default = ["10.244.231.10", "10.244.232.10", "10.244.233.10"]
}

variable disk_prefix {
  default = "glusterfs-brick"
}

variable data_disk_size {
  default = "100"
}

variable machine_type {
  default = "n1-standard-1"
}

variable boot_disk_size {
  default     = "10"
  description = "Boot disk size of instances. Use 200G or above to have high network throughput"
}

variable cluster_size {
  default = 3
}

variable disk_type {
  default = "pd-ssd"
}

variable image {
  default = "ubuntu-1604-xenial-v20180522"
}

variable network {
  default = "beta"
}

variable tags {
  default = ["glusterfs"]
}

variable kubernetes_endpoint_name {
  default = "glusterfs-cluster"
}

variable disk_snapshot {
  default = ""
}
