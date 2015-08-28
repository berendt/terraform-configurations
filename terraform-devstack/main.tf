provider "openstack" {
  user_name  = "${var.user_name}"
  tenant_name = "${var.tenant_name}"
  password  = "${var.password}"
  auth_url  = "${var.auth_url}"
}

resource "openstack_networking_network_v2" "terraform" {
  name = "terraform"
  region = "${var.region}"
  admin_state_up = "true"
}

resource "openstack_compute_keypair_v2" "terraform" {
  name = "SSH keypair for Terraform instances"
  region = "${var.region}"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_subnet_v2" "terraform" {
  name = "terraform"
  region = "${var.region}"
  network_id = "${openstack_networking_network_v2.terraform.id}"
  cidr = "192.168.50.0/24"
  ip_version = 4
  enable_dhcp = "true"
  dns_nameservers = ["208.67.222.222","208.67.220.220"]
}

resource "openstack_networking_router_v2" "terraform" {
  name = "terraform"
  region = "${var.region}"
  admin_state_up = "true"
  external_gateway = "${var.external_gateway}"
}

resource "openstack_networking_router_interface_v2" "terraform" {
  region = "${var.region}"
  router_id = "${openstack_networking_router_v2.terraform.id}"
  subnet_id = "${openstack_networking_subnet_v2.terraform.id}"
}

resource "openstack_compute_floatingip_v2" "terraform" {
  depends_on = ["openstack_networking_router_interface_v2.terraform"]
  region = "${var.region}"
  pool = "public"
}

resource "openstack_compute_secgroup_v2" "terraform" {
  name = "terraform"
  region = "${var.region}"
  description = "Security group for the Terraform instances"
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "udp"
    cidr = "0.0.0.0/0"
  }
  rule {
    ip_protocol = "icmp"
    from_port = "-1"
    to_port = "-1"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "terraform" {
  name = "terraform"
  region = "${var.region}"
  image_name = "${var.image}"
  flavor_name = "${var.flavor}"
  key_pair = "${openstack_compute_keypair_v2.terraform.name}"
  security_groups = [ "${openstack_compute_secgroup_v2.terraform.name}" ]
  floating_ip = "${openstack_compute_floatingip_v2.terraform.address}"

  network {
    uuid = "${openstack_networking_network_v2.terraform.id}"
  }

  provisioner "remote-exec" {
    script = "deploy.sh"
    connection {
      user = "${var.ssh_user_name}"
      key_file = "${var.ssh_key_file}"
    }
  }
}
