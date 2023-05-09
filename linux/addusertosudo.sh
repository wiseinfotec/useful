#!/bin/sh

u=$1
s=$2

cd /etc/sudoers.d
t=${u}" ALL=(ALL) NOPASSWD:ALL"

echo ${t} > ${u}
chmod 0440 ${u}

echo ${t}
ls -la

adduser ${u}
usermod -aG sudo ${u}

mkdir -p /home/${u}/.ssh
cd /home/${u}/.ssh
touch authorized_keys
chown -R ${u}:${u} /home/${u}/.ssh
chmod 0755 -R /home/${u}/.ssh

visudo -c
