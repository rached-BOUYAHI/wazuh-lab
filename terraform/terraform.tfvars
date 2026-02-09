#cloud           = "YOUR_CLOUD_NAME"
region          = "RegionOne"
#keypair_name    = "your-keypair"

# Must match your OpenStack names
wan_network_name = "public1"
man_network_name = "base-net"

# Optional but recommended: lock SSH to your public IP
#allowed_ssh_cidr = "YOUR.PUBLIC.IP/32"

# If you want a floating ip on MAN (bastion)
floatingip_pool = "public1"

# Adjust if your MAN subnet differs
man_cidr = "192.168.66.0/24"
