resource "random_id" "flatcar-suffix" {
  byte_length = 8
}

# we let 'Nova' generate a new keypair.
resource "openstack_compute_keypair_v2" "provisioning_keypair" {
  name = "Provisioning key for Flatcar cluster ${var.cluster_name}-${random_id.flatcar-suffix.hex}"
}

# keypair is saved locally for later SSH connections.
resource "local_file" "provisioning_key" {
  filename             = "${path.module}/.ssh/provisioning_private_key.pem"
  content              = openstack_compute_keypair_v2.provisioning_keypair.private_key
  directory_permission = "0700"
  file_permission      = "0400"
}

resource "local_file" "provisioning_key_pub" {
  filename             = "${path.module}/.ssh/provisioning_key.pub"
  content              = openstack_compute_keypair_v2.provisioning_keypair.public_key
  directory_permission = "0700"
  file_permission      = "0440"
}

data "openstack_images_image_v2" "flatcar" {
  name        = "terraform-flatcar-stable"
  most_recent = true
}

# Get the flavor ID
data "openstack_compute_flavor_v2" "flatcar" {
  name = var.flavor_name
}

# 'instance' are the OpenStack instances created from the 'flatcar' image
# using user data.
resource "openstack_compute_instance_v2" "instance" {
  for_each  = toset(var.machines)
  name      = "${var.cluster_name}-${each.key}-${random_id.flatcar-suffix.hex}"
  image_id  = data.openstack_images_image_v2.flatcar.id
  flavor_id = data.openstack_compute_flavor_v2.flatcar.id
  key_pair  = openstack_compute_keypair_v2.provisioning_keypair.name

  network {
    name = "public"
  }

  user_data = data.ct_config.machine-ignitions[each.key].rendered

  security_groups = flatten([["default"], var.ssh ? [openstack_networking_secgroup_v2.ssh[0].name] : []])
}

data "ct_config" "machine-ignitions" {
  for_each = toset(var.machines)
  strict   = true
  content  = file("${path.module}/server-configs/${each.key}.yaml")
  snippets = [
    local.core_user
  ]
}

locals {
  core_user = templatefile("${path.module}/core-user.yaml.tmpl", {
    ssh_keys = jsonencode(concat(var.ssh_keys, [openstack_compute_keypair_v2.provisioning_keypair.public_key]))
  })
}
