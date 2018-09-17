# terraform-glusterfs
This module creates Glusterfs cluster and provides endpoints to use with kubernetes. By default cluster is set to three GlusterFS servers, one server per Google Cloud zone in the same chosen region.

![Architecture](images/glusterf-gce-architecture.png)

## Prerequisites

Before continuing, please make sure you have:

* A [Google Cloud](https://cloud.google.com) account
* The [Google Cloud SDK](https://cloud.google.com/sdk/) installed

## 1. Features

- multi-node glusterfs server is created 
- possibility to create multiple glusterfs volumes
- outputs ready to use kubernetes endpoint config in json
- configurable subnet masks
- configurable disk sizes and types


## 2. Usage:

define cluster module:

```hcl
module "cluster" {
  source         = "github.com/russmedia/terraform-google-glusterfs?ref=0.0.1"
  server_prefix  = "${var.server_prefix}"
  disk_prefix    = "${var.disk_prefix}"
  subnet_mask    = "${var.subnet_mask}"
  ip_offset      = "${var.ip_offset}"
  data_disk_size = "${var.data_disk_size}"
  network        = "${var.network}"
  subnetwork     = "${var.subnetwork}"
  disk_snapshot  = "${var.disk_snapshot}"
  disk_type      = "pd-standard (can also be pd-ssd if you need speed)"
  volume_names   = "${var.volume_names}"
  tags           = "${var.tags}"
}
```


and set your variables:

```hcl

variable network {}
variable subnetwork {}

variable server_prefix {}
variable disk_prefix {}

variable subnet_mask {
  default = "10.10.0.0/24"
}

variable ip_offset {
  default = 3
}

variable volume_names {
  type = "list"
}

variable data_disk_size {}

variable disk_snapshot {
  default = ""
}
```

example setup could be as follows:

```hcl
disk_prefix = "glusterfs-brick"

server_prefix = "glusterfs-server"

data_disk_size = "your-chosen-disk-size i.e. 500"

network = "your-exisiting-network"

subnetwork = "subnetwork-name-that-module-will-create-for-you"

disk_snapshot = "gluster-snapshot-name"

volume_names = ["your-volume-name"]

project = "your-project-name"

subnet_mask = "10.0.0.0/24"

tags = ["first_tag", "second_tag"]
```

for more settings please look into ![variables.tf](variables.tf)

### 2.1. Connecting with Kubernetes

1. Apply Kubernetes endpoints and svc files to the cluster:
```
kubectl apply -f glusterfs-endpoints.json
kubectl apply -f files/glusterfs-svc.json
```
IMPORTANT note - to make gluster endpoint work persistently in your kubernetes cluster you need to apply glusterfs-endpoints.json (defined in variable kubernetes_endpoint_file_path) and glusterfs-svc.json (located in files folder)

2. Sample mount in deployment:
```yml
(...)
  spec:
      containers:
      - image: nginx
        (...)
        volumeMounts:
        - mountPath: /mnt/glusterfs
          name: glusterfs-vol
      volumes:
      - name: glusterfs-vol
        glusterfs:
          endpoints: glusterfs-cluster
          path: volume_name
          readOnly: false
```

## 3. Authors

- [Eryk Zalejski](https://github.com/ezalejski)

- [Filip Haftek](https://github.com/filiphaftek)


## 4. License

This project is licensed under the MIT License - see the LICENSE.md file for details.
Copyright (c) 2018 Russmedia GmbH.

# Acknowledgments

Terraform module is based on [glusterfs-gce repository](https://github.com/rimusz/glusterfs-gce)