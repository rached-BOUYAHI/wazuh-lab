variable "cloud" {
  type        = string
  description = "Name of the cloud in clouds.yaml"
}

variable "region" {
  type        = string
  description = "OpenStack region (optional)"
  default     = null
}

variable "image_name" {
  type        = string
  default     = "ubuntu-noble-x86_64"
}

variable "man_flavor" {
  type        = string
  default     = "standard.medium"
}

variable "wazuh_flavor" {
  type        = string
  default     = "standard.large"
}

variable "keypair_name" {
  type        = string
  description = "OpenStack keypair name"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
}

variable "wan_network_name" {
  type        = string
  default     = "public1"
}

variable "man_network_name" {
  type        = string
  default     = "base-net"
}

variable "floatingip_pool" {
  type        = string
  default     = null
  description = "If set, allocate a floating IP from this pool for MAN"
}

variable "allowed_ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Who can SSH to MAN (set to your public IP /32 ideally)"
}

variable "man_cidr" {
  type        = string
  default     = "192.168.66.0/24"
  description = "CIDR of MAN network (used for SG rules)"
}

variable "man_name" {
  type    = string
  default = "man-01"
}

variable "wazuh_name" {
  type    = string
  default = "wazuh-01"
}
