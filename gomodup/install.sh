#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo "Please run as root or sudo." >&2
    exit 1
fi

if [[ -z $(which go) ]]; then
    echo "go is not installed. Run 'sudo dnf install golang' to install it." >&2
    exit 1
fi

if [[ -z $(which dialog) ]]; then
    echo "dialog is not installed. Run 'sudo dnf install dialog' to install it." >&2
    exit 1
fi

cp -f gomodup.sh /usr/bin/gomodup
chmod +x /usr/bin/gomodup

echo "Installation done."
