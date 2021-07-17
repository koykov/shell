#!/bin/sh

if (( $EUID != 0 )); then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [[ -z $(which go) ]]; then
    echo "go is not installed. Run 'sudo dnf install golang' to install it." >&2
    exit 1
fi


cp -f gomodln.sh /usr/bin/gomodln
chmod +x /usr/bin/gomodln

echo "Installation done."
