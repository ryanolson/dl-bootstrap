#!/usr/bin/env bash

# Ensure running as regular user
if [ $(id -u) -eq 0 ] ; then
    echo "Please run as a regular user"
    exit 1
fi

# Install newer version of Ansible
if ! type ansible > /dev/null; then
  sudo apt-get -y install software-properties-common
  sudo apt-add-repository -y ppa:ansible/ansible
  sudo apt-get update
  sudo apt-get -y install ansible
fi

# Add nvidia-docker role from Ansible Galaxy
ansible-galaxy install -r requirements.yml --roles-path=./roles

# Write playbook
playbook=$(mktemp)
cat <<EOF > $playbook
- hosts: all
  roles:
    - role: 'ryanolson.basics'
      become: true
    - role: 'ryanolson.nvidia-driver'
      become: true
    - role: 'ryanolson.docker'
      become: true
      docker_users:
      - "{{ ansible_user_id }}"
    - role: 'ryanolson.nvidia-docker'
      become: true
    - role: 'cmprescott.chrome'
      become: true
    - role: 'softasap.sa-chrome-remote-desktop'
      become: true
    - role: 'ryanolson.dotfiles'
EOF

# Execute playbook
ansible-playbook --ask-become-pass -i "localhost," -c local $playbook

# cleanup
rm -f $playbook
exit
