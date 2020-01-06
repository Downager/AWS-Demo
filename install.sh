#!/bin/bash
set -e # for errexit

ansible-playbook -i hosts playbook_ubuntu_install_docker.yaml
ansible-playbook -i hosts playbook_create_user_and_group.yaml
ansible-playbook -i hosts playbook_deploy_nginx_container.yaml