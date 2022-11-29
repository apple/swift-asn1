#!/bin/sh

set -eu

mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

#cp -r /root/.ssh/* ~/.ssh/
#chown -R $(id -u):$(id -g) ~/.ssh

#cat <<EOF >> ~/.ssh/config
#  User $SSH_USER
#EOF

