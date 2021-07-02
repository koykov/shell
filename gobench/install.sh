#!/bin/sh

if (( $EUID != 0 )); then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [[ -z $(which go) ]]; then
    echo "go is not installed. Run 'sudo dnf install golang' to install it." >&2
    exit 1
fi


cp -f gobench.sh /usr/bin/gobench
chmod +x /usr/bin/gobench

cp -f membench.sh /usr/bin/membench
chmod +x /usr/bin/membench

cp -f cpubench.sh /usr/bin/cpubench
chmod +x /usr/bin/cpubench

echo "Installation done."
