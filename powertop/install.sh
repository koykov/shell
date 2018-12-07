#!/bin/sh

if (( $EUID != 0 )); then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [ ! -f "custom.sh" ]; then
    echo "custom.sh doesn't exists. Check readme.md for details." >&2
    exit 1
fi

cp -f powertop-at-alter.service /etc/systemd/system/powertop-at-alter.service
systemctl enable powertop-at-alter.service
echo "Service has installed."
cp -f custom.sh /usr/sbin/powertop-custom
chmod +x /usr/sbin/powertop-custom
echo "Custom commands has registered."
echo "Reboot or run manually 'systemctl start powertop-at-alter.service'"
