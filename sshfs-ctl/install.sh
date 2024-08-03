#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [[ -z $(which sshfs) ]]; then
    echo "sshfs is not installed. Run 'sudo dnf install sshfs' to install it." >&2
    exit 1
fi

cp -f sshfs-ctl.sh /usr/bin/sshfs-ctl
chmod +x /usr/bin/sshfs-ctl

cp -f sshfs-up.sh /usr/bin/sshfs-up
chmod +x /usr/bin/sshfs-up

cp -f sshfs-down.sh /usr/bin/sshfs-down
chmod +x /usr/bin/sshfs-down

cp -f options /usr/bin/sshfs-options

echo "Installation done. Now commands sshfs-ctl, sshfs-up and sshfs-down are available."
