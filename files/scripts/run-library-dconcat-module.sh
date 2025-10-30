#!/bin/sh

export SEP_LINE_NL="\n-------------------------------------------------------------------------------\n"

SETUP_SOURCE_FILE="setup.sh"

# ---------------------------------------------------------------------
# Sourcing the setup file to setup and teardown the demo script
# ---------------------------------------------------------------------

setup() {
if [ -f "$SETUP_SOURCE_FILE" ]; then
  echo "[INFO] Sourcing $SETUP_SOURCE_FILE."
  source "$SETUP_SOURCE_FILE"
else
  echo "The setup file $SETUP_SOURCE_FILE must exist and be run."
  exit
fi
}

# ---------------------------------------------------------------------
# Export the custom module library path to Ansible
# ---------------------------------------------------------------------
setup
echo "${SEP_LINE_NL}[INFO] Sharing the custom module library path with Ansible.${SEP_LINE_NL}"
export ANSIBLE_LIBRARY=${MY_ANSIBLE_LIBRARY:=$ANSIBLE_LIBRARY}

# ---------------------------------------------------------------------
# Run Ansible Playbook
# ---------------------------------------------------------------------

echo "${SEP_LINE_NL}[INFO] Run Custom Anaible module with module default${SEP_LINE_NL}"
ansible-playbook -i ../../playbooks/inventory ../../playbooks/zos_dconcat.yml

setup
echo "${SEP_LINE_NL}[INFO] Run Custom Anaible module with merge option.{SEP_LINE_NL}"
ansible-playbook -i ../../playbooks/inventory ../../playbooks/zos_dconcat_merge.yml

setup
echo "${SEP_LINE_NL}[INFO] Run Custom Anaible module with reverse option${SEP_LINE_NL}"
ansible-playbook -i ../../playbooks/inventory ../../playbooks/zos_dconcat_reverse.yml

echo "${SEP_LINE_NL}[INFO] Demonstrate module doc.${SEP_LINE_NL}"
ansible-doc zos_dconcat