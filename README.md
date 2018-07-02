# Bootstrap HA GlusterFS Cluster in GCE

* This project bootstraps off-cluster HA GlusterFS Cluster.
By default it is set to three GlusterFS servers, one server per Google Cloud zone in the same chosen region.

![Architecture](images/glusterf-gce-architecture.png)

## Prerequisites

Before continuing, please make sure you have:

* A [Google Cloud](https://cloud.google.com) account
* The [Google Cloud SDK](https://cloud.google.com/sdk/) installed
* [Terraform] (https://www.terraform.io/) installed
* Google bucket for tfstate

## Create cluster:

1. Insert bucket name into `terraform/google.tf` file.

2. Use terraform to create cluster
```
cd terraform
terraform plan -var-file=environments/test.tfvars -out=.tfplan
terraform apply ".tfplan"
```
Note: you can create pure cluster or use snaphot for creating data disks (`variable disk_snapshot`) in `environments/test.tfvars` file.

3. Check if all cluster boxes have properly mounted:

On every box invoke:
```
df -h | grep sdb
```
Output should be similar to:
```
/dev/sdb       1000G  1.1G  999G   1% /data/brick1
```

Note: If any box has not mounted `/data` dir, please destroy box manually and use terraform again to create it.
This is probably a bug in terraform and mounting disks resource on Google Cloud Platform.
4. On `glusterfs-server-0` do:
```
sudo gluster peer probe glusterfs-server-1
sudo gluster peer probe glusterfs-server-2
export VOLUME_NAME=volume_test1
sudo gluster volume create $VOLUME_NAME replica 3 glusterfs-server-0:/data/brick1/$VOLUME_NAME glusterfs-server-1:/data/brick1/$VOLUME_NAME glusterfs-server-2:/data/brick1/$VOLUME_NAME force # replica is the number of boxes  
sudo gluster volume start $VOLUME_NAME
```
Check if cluster is working properly:
```
sudo gluster volume info
```
Additionaly, to enable bitrot scrubbing (biweekly) [About](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/administration_guide/chap-detecting_data_corruption)
```
sudo gluster volume bitrot $VOLUME enable
```

## Use with Kubernetes
```
cd kubernetes-usage-sample
kubectl apply -f glusterfs-endpoints.json # if static ip's changed in terraform, please albo update them in this file
kubectl apply -f glusterfs-svc.json
kubectl apply -f glusterfs-sample.json
```

# Acknowledgments

Terraform module is based on [glusterfs-gce repository](https://github.com/rimusz/glusterfs-gce)