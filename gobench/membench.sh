#!/bin/bash

if ! command -v gobench &> /dev/null
then
    echo "gobench: command not found."
    exit 1
fi

/usr/bin/gobench mem "$@"
