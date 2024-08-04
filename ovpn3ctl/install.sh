#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [[ -z $(which openvpn3) ]]; then
    echo "openvpn3 is not installed. Visit https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux and follow installation instructions." >&2
    exit 1
fi

if [[ -z $(which dialog) ]]; then
    echo "dialog is not installed. Run 'sudo apt install dialog' to install it." >&2
    exit 1
fi

cp -f ovpn3ctl.sh /usr/bin/ovpn3ctl
chmod +x /usr/bin/ovpn3ctl

echo "Installation done."
