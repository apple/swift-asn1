#!/bin/sh

set -eu

mkdir -p ~/.ssh
ssh-keyscan github.com >> /root/.ssh/known_hosts
echo "Host *\n  StrictHostKeyChecking no" > /root/.ssh/config

#cp -r /root/.ssh/* ~/.ssh/
#chown -R $(id -u):$(id -g) ~/.ssh

#cat <<EOF >> ~/.ssh/config
#  User $SSH_USER
#EOF

