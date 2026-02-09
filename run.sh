#!/usr/bin/env bash
set -euo pipefail

cd terraform

# Init + apply
tofu init
tofu apply -auto-approve

cd ..
./scripts/gen_inventory.sh terraform ansible

cd ansible
ansible -m ping man
ansible -m ping wazuh
ansible-playbook playbook.yml
