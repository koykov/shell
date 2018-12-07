#!/bin/bash

LOG="/var/log/turbo-boost-ctl.log"
echo $(date '+%Y-%m-%d %H:%M:%S') >> $LOG

config="/etc/turbo-boost"

if [ ! -f $config ]; then
    echo "config file $config doesn't exists." >> $LOG
    exit 1
fi

status=$(head -n 1 $config)

if [[ $status != "enable" && $status != "disable" ]]; then
    echo "Invalid argument: $status" >> $LOG
    echo "Posiible values: [disable|enable]" >> $LOG
    exit 1
fi

cores=$(cat /proc/cpuinfo | grep processor | awk '{print $3}')
for core in $cores; do
    if [[ $status == "disable" ]]; then
        wrmsr -p${core} 0x1a0 0x4000850089
    fi
    if [[ $status == "enable" ]]; then
        wrmsr -p${core} 0x1a0 0x850089
    fi
    state=$(rdmsr -p${core} 0x1a0 -f 38:38)
    if [[ $state -eq 1 ]]; then
        echo "core ${core}: disabled" >> $LOG
    else
        echo "core ${core}: enabled" >> $LOG
    fi
done
