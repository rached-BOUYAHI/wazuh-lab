# Wazuh Lab (OpenTofu + Ansible on OpenStack)

## Prereqs
- OpenTofu (or Terraform) installed
- Ansible installed
- OpenStack credentials in clouds.yaml

## Setup
1) Copy terraform/terraform.tfvars.example to terraform/terraform.tfvars and edit:
   - cloud
   - region
   - keypair_name
   - wan_network_name
   - man_network_name
   - floatingip_pool
   - allowed_ssh_cidr (strongly recommended)

2) Run:
   ./run.sh

## Outputs
- MAN is reachable via floating IP
- Wazuh is reached over MAN network via ProxyJump
- Wazuh AIO installed on wazuh-01

## Cleanup
cd terraform
tofu destroy -auto-approve
