#!/bin/sh

if (( $EUID != 0 )); then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [[ -z $(which redshift) ]]; then
    echo "redshift is not installed. Run 'sudo dnf install redshift' to install it." >&2
    exit 1
fi

echo -e "\n[redshift]\nallowed=true\nsystem=false\nusers=\n" >> /etc/geoclue/geoclue.conf
echo "Geoclue2 config has patched."

systemctl restart geoclue.service
echo "Service has reloaded. Reboot or relaunch Redshift manually."
