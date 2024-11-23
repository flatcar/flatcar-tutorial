# Hands-on 3: deploying

Hello, the goal here is to:
* deploy Flatcar instances with IaC (Terraform)
* manipulate Terraform code
* write Flatcar provisioning with Terraform
* deploy Flatcar on OpenStack with Terraform

This is a bundle of hands-on-1 and hands-on-2 but it's not locally now and we write _everything_ as code.

If you have your **own** OpenStack instance, you can apply the following diff to create the Flatcar image. Otherwise, proceed to the step-by-step as usual.
```diff
diff --git a/hands-on-3/terraform/compute.tf b/hands-on-3/terraform/compute.tf
index 942de77..e8a81b0 100644
--- a/hands-on-3/terraform/compute.tf
+++ b/hands-on-3/terraform/compute.tf
@@ -22,9 +22,13 @@ resource "local_file" "provisioning_key_pub" {
   file_permission      = "0440"
 }

-data "openstack_images_image_v2" "flatcar" {
-  name        = "terraform-flatcar-stable"
-  most_recent = true
+# We create the OpenStack image by importing directly from the release servers.
+resource "openstack_images_image_v2" "flatcar" {
+  name             = "flatcar-stable"
+  image_source_url = "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_openstack_image.img.gz"
+  container_format = "bare"
+  disk_format      = "qcow2"
+  web_download     = true
 }

 # Get the flavor ID
@@ -37,7 +41,7 @@ data "openstack_compute_flavor_v2" "flatcar" {
 resource "openstack_compute_instance_v2" "instance" {
   for_each  = toset(var.machines)
   name      = "${var.cluster_name}-${each.key}-${random_id.flatcar-suffix.hex}"
-  image_id  = data.openstack_images_image_v2.flatcar.id
+  image_id  = openstack_images_image_v2.flatcar.id
   flavor_id = data.openstack_compute_flavor_v2.flatcar.id
   key_pair  = openstack_compute_keypair_v2.provisioning_keypair.name
```

# Step-by-step

```bash
# go into the terraform directory
cd terraform
# download terraform
wget https://releases.hashicorp.com/terraform/1.5.4/terraform_1.5.4_linux_amd64.zip
unzip terraform_1.5.4_linux_amd64.zip
rm terraform_1.5.4_linux_amd64.zip
# update the config for creating index.html from previous hands-on
vim server-configs/server1.yaml
# init the terraform project locally
./terraform init
# get the credentials from Mathieu and update the `terraform.tfvars` consequently
# generate the plan and inspect it
./terraform plan
# apply the plan
./terraform apply
# go on the horizon dashboard and connect with terraform credentials
# find your instance
```

One can assert that it works by accessing the console (click on the instance then "console")

_NOTE_: it's possible to SSH into the instance but at the moment, it takes a SSH jump through the openstack (devstack) instance. If the group is small enough, you can ask Mathieu or Kai to install a public key to the demo server.
```
ssh -J user@[DEVSTACK-IP] -i ./.ssh/provisioning_private_key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@[SERVER-IP]
```

To destroy the instance:
```
# if you are happy, destroy everything
./terraform destroy
```

# Resources

* https://github.com/flatcar/flatcar-terraform/ (NOTE: the terraform code used here is based on this repository)
* https://www.flatcar.org/docs/latest/installing/cloud/openstack/

# Demo

```
asciinema play demo.cast
```

or: https://asciinema.org/a/591442

## Instructions for Apple Silicon (M1/M2) Users

If you're using an Apple Silicon Mac (M1/M2) and encounter this error:

```plaintext
Error: Incompatible provider version
Provider registry.terraform.io/hashicorp/template v2.2.0 does not have a package 
available for your current platform, darwin_arm64.
```

Replace the following files with their ARM-compatible versions:
- Copy `provider.tf.arm` to `provider.tf`
- Copy `compute.tf.arm` to `compute.tf`

These ARM-compatible versions use the built-in templatefile function instead of the template provider, which resolves the ARM64 compatibility issue.