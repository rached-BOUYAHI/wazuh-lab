#!/usr/bin/env bash
set -euo pipefail

TF_DIR="${1:-terraform}"
ANS_DIR="${2:-ansible}"

MAN_FIP="$(tofu -chdir="$TF_DIR" output -raw man_floating_ip || true)"
MAN_MAN_IP="$(tofu -chdir="$TF_DIR" output -raw man_man_ip)"
WAZUH_MAN_IP="$(tofu -chdir="$TF_DIR" output -raw wazuh_man_ip)"

if [[ -z "${MAN_FIP}" || "${MAN_FIP}" == "null" ]]; then
  echo "ERROR: man_floating_ip is null. Either set floatingip_pool or ensure you can reach MAN another way."
  exit 1
fi

cat > "${ANS_DIR}/inventory.ini" <<EOF
[man]
man ansible_host=${MAN_FIP} ansible_user=ubuntu

[wazuh]
wazuh ansible_host=${WAZUH_MAN_IP} ansible_user=ubuntu ansible_ssh_common_args='-o ProxyJump=ubuntu@${MAN_FIP} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF

echo "Wrote ${ANS_DIR}/inventory.ini"
echo "MAN_FIP=${MAN_FIP}"
echo "MAN_MAN_IP=${MAN_MAN_IP}"
echo "WAZUH_MAN_IP=${WAZUH_MAN_IP}"
