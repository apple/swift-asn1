#!/bin/bash

set -eu

mkdir -p ~/.ssh
cp -r /root/.ssh-keys/* ~/.ssh/
chown -R $(id -u):$(id -g) ~/.ssh

cat <<EOF >> ~/.ssh/config
  User $SSH_USER
EOF
