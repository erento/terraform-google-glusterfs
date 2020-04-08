variable "project" {
  description = "Google project name"
}

variable "region" {
  description = <<EOF
  Google region i.e. "europe-west1"
EOF

}

variable "zones" {
  type        = list(string)
  description = <<EOF
  Google zones i.e. ["b", "c", "d"]
  Number of zones needs to be equal or greater than cluster size.
EOF

}

variable "server_prefix" {
  default = "glusterfs-server"
}

variable "network" {
  description = "Network Name on Google Cloud to place the gluster cluster in - this needs to exist"
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork Name on Google Cloud to place the gluster cluster in - this will be created"
  default     = "default"
}

variable "volume_names" {
  description = "Names of the volumes that module creates"
  type        = list(string)
}

variable "subnet_mask" {
  description = "Network CIDR to place the gluster cluster in"
  default     = "10.0.0.0/24"
}

variable "ip_offset" {
  description = "We are using last bit of the 'subnet_mask' i.e. 10.0.0.254, 10.0.0.253 - increase if you those IPs are alredy taken"
  default     = 3
}

variable "replicas_number" {
  description = "How many replicas of each file should gluster keep"
  default     = 3
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "cluster_size" {
  default = 3
}

variable "boot_disk_size" {
  default     = "10"
  description = "VMs disk boot size in GB"
}

variable "boot_disk_type" {
  default     = "pd-standard"
  description = "VMs disk boot type (pd-standard or pd-ssd)"
}

variable "data_disk_size" {
  default     = "100"
  description = "GlusterFS data disk size in GB"
}

variable "data_disk_type" {
  default = "pd-ssd"
}

variable "data_disk_prefix" {
  default = "glusterfs-brick"
}

variable "data_disk_snapshot" {
  default = ""
}

variable "image" {
  description = "Linux Image to use as a system disk"
  default     = "ubuntu-1604-xenial-v20180522"
}

variable "tags" {
  type    = list(string)
  default = ["gluster"]
}

variable "allowed_source_tags" {
  description = "Source tags on Google Cloud that will have access to gluster"
  type        = list(string)
  default     = ["gluster"]
}

variable "kubernetes_endpoint_name" {
  default = "glusterfs-cluster"
}

variable "kubernetes_endpoint_file_path" {
  default     = "glusterfs-endpoints.json"
  description = "Path to Kubernetes endpoint file generated by terraform"
}

variable "vm_dns_setting" {
  default     = "GlobalOnly"
  description = <<EOF
  Please see https://cloud.google.com/compute/docs/internal-dns.
  Set VmDnsSetting=ZonalOnly to have your instances be addressable only by their zonal DNS names. The instances still retain both the zonal and global search paths, but their global DNS names no longer function. Other instances can address instances with this setting using only their zonal DNS names and can't address these instances using their global DNS names or search paths. This is the preferred option as long as your apps can support it. This is the default setting for instances in standalone projects and projects created in an organization that enable the Compute Engine API after September 6, 2018. Note that, if a project is migrated to an organization, the default DNS name for that project doesn't change. 
  Set VmDnsSetting=ZonalPreferred to enable zonal DNS search paths while still retaining the global DNS name. Instances with this setting can address each other using either zonal or global DNS names and can continue to address instances configured only for global DNS names. 
  Set VmDnsSetting=GlobalOnly so that instances use only global names as domain names and search path entries. Use this value to exclude instances from a project-wide zonal DNS setting or to restore your instances to use only global DNS names. This is the default setting for instances in standalone projects and projects created in an organization that enabled the Compute Engine API before September 6, 2018. Note that, if a project is migrated to an organization, the default DNS name for that project doesn't change.
EOF

}

