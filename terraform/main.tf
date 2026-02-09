provider "openstack" {
#  cloud  = var.cloud
#  region = var.region
}

data "openstack_networking_network_v2" "wan" {
  name = var.wan_network_name
}

data "openstack_networking_network_v2" "man" {
  name = var.man_network_name
}

# -----------------------------
# Security Groups
# -----------------------------

resource "openstack_networking_secgroup_v2" "man_ingress" {
  name        = "sg-man-ingress"
  description = "Allow SSH to MAN from allowed CIDR"
}

resource "openstack_networking_secgroup_rule_v2" "man_ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.allowed_ssh_cidr
  security_group_id = openstack_networking_secgroup_v2.man_ingress.id
}

resource "openstack_networking_secgroup_v2" "wazuh_from_man" {
  name        = "sg-wazuh-from-man"
  description = "Allow MAN network to reach Wazuh ports"
}

# SSH from MAN network
resource "openstack_networking_secgroup_rule_v2" "wazuh_ssh_from_man" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.man_cidr
  security_group_id = openstack_networking_secgroup_v2.wazuh_from_man.id
}

# Wazuh ports (MAN -> Wazuh)
resource "openstack_networking_secgroup_rule_v2" "wazuh_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 55000
  port_range_max    = 55000
  remote_ip_prefix  = var.man_cidr
  security_group_id = openstack_networking_secgroup_v2.wazuh_from_man.id
}

resource "openstack_networking_secgroup_rule_v2" "wazuh_dashboard" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5601
  port_range_max    = 5601
  remote_ip_prefix  = var.man_cidr
  security_group_id = openstack_networking_secgroup_v2.wazuh_from_man.id
}

resource "openstack_networking_secgroup_rule_v2" "wazuh_agent_tcp_1514" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1514
  port_range_max    = 1514
  remote_ip_prefix  = var.man_cidr
  security_group_id = openstack_networking_secgroup_v2.wazuh_from_man.id
}

resource "openstack_networking_secgroup_rule_v2" "wazuh_agent_udp_1514" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1514
  port_range_max    = 1514
  remote_ip_prefix  = var.man_cidr
  security_group_id = openstack_networking_secgroup_v2.wazuh_from_man.id
}

resource "openstack_networking_secgroup_rule_v2" "wazuh_agent_1515" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1515
  port_range_max    = 1515
  remote_ip_prefix  = var.man_cidr
  security_group_id = openstack_networking_secgroup_v2.wazuh_from_man.id
}

# -----------------------------
# Ports (apply SGs cleanly)
# -----------------------------

resource "openstack_networking_port_v2" "man_wan" {
  name       = "${var.man_name}-wan"
  network_id = data.openstack_networking_network_v2.wan.id
}

resource "openstack_networking_port_v2" "man_man" {
  name               = "${var.man_name}-man"
  network_id         = data.openstack_networking_network_v2.man.id
  security_group_ids = [openstack_networking_secgroup_v2.man_ingress.id]
}

resource "openstack_networking_port_v2" "wazuh_wan" {
  name       = "${var.wazuh_name}-wan"
  network_id = data.openstack_networking_network_v2.wan.id
}

resource "openstack_networking_port_v2" "wazuh_man" {
  name               = "${var.wazuh_name}-man"
  network_id         = data.openstack_networking_network_v2.man.id
  security_group_ids = [openstack_networking_secgroup_v2.wazuh_from_man.id]
}

# -----------------------------
# Instances
# -----------------------------

resource "openstack_compute_instance_v2" "man" {
  name       = var.man_name
  image_name = var.image_name
  flavor_name = var.man_flavor
  key_pair   = var.keypair_name

  network { port = openstack_networking_port_v2.man_wan.id }
  network { port = openstack_networking_port_v2.man_man.id }

  user_data = <<-CLOUD
  #cloud-config
  package_update: true
  packages:
    - python3
    - curl
    - jq
    - netcat-openbsd
  CLOUD
}

resource "openstack_compute_instance_v2" "wazuh" {
  name       = var.wazuh_name
  image_name = var.image_name
  flavor_name = var.wazuh_flavor
  key_pair   = var.keypair_name

  network { port = openstack_networking_port_v2.wazuh_wan.id }
  network { port = openstack_networking_port_v2.wazuh_man.id }

  user_data = <<-CLOUD
  #cloud-config
  package_update: true
  packages:
    - python3
    - curl
    - unzip
  CLOUD
}

# -----------------------------
# Floating IP for MAN (optional)
# -----------------------------

resource "openstack_networking_floatingip_v2" "man_fip" {
  count = var.floatingip_pool == null ? 0 : 1
  pool  = var.floatingip_pool
}

resource "openstack_compute_floatingip_associate_v2" "man_fip_assoc" {
  count       = var.floatingip_pool == null ? 0 : 1
  floating_ip = openstack_networking_floatingip_v2.man_fip[0].address
  instance_id = openstack_compute_instance_v2.man.id
}
