#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [[ -z $(which rdmsr) ]]; then
    echo "msr-tools is not installed. Run 'sudo dnf install msr-tools' to install it." >&2
    exit 1
fi

if [ ! -f "config" ]; then
    echo "config doesn't exists. Check readme.md for details." >&2
    exit 1
fi

cp -f turbo-boost-ctl.service /etc/systemd/system/turbo-boost-ctl.service
systemctl enable turbo-boost-ctl.service
echo "Service has installed."
cp -f config /etc/turbo-boost
cp -f turbo-boost-ctl.sh /usr/sbin/turbo-boost-ctl
chmod +x /usr/sbin/turbo-boost-ctl
echo "Control script has installed."
echo "Reboot or run manually 'systemctl start turbo-boost-ctl.service'"
