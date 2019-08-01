#!/bin/sh

action="up"
user=""
pass=""
host=""
dir=""
mount_point=""
verbose=0
server=""
options=""

# Parse options
while [[ "$#" -gt 0 ]]; do
    case $1 in
      -a|--action) action="$2"; shift;;
      -u|--user) user="$2"; shift;;
      -p|--pass) pass="$2"; shift;;
      -h|--host) host="$2"; shift;;
      -d|--dir) dir="$2"; shift;;
      -m|--mount-point) mount_point="$2"; shift;;
      -v|--verbose) verbose=1; shift;;
      *) server="$1"; shift;;
    esac;
done

# Read from .ssh/config
if [[ ${server} ]]
then
    shopt -s nocasematch
    user=`ssh -G ${server} | grep -m 1 "user " | cut -d' ' -f 2`
    host=${server}
    hostname=`ssh -G ${server} | grep -m 1 "hostname " | cut -d' ' -f 2`
    port=`ssh -G ${server} | grep -m 1 "port " | cut -d' ' -f 2`
fi

# checks
if [[ -z "$port" ]]
then
    port="22"
fi

if [[ -z "$port" ]]
then
    port="22"
fi

if [[ -z "$dir" ]]
then
    dir="/home/$user"
fi

if [[ -z "$mount_point" ]]
then
    mount_point="$HOME/rem/$host"
    mkdir -p ${mount_point}
fi

if [[ -f "options" ]]
then
    options=`cat options`
fi

# compose command
cmd="sshfs -p $port $user@$host:$dir $mount_point $options"
if [[ "$pass" != "" ]]
then
    cmd="echo \"$pass\" | $cmd -o password_stdin"
fi
if [[ "$action" == "down" ]]
then
    pid=`ps ax | grep -m 1 "$cmd" | cut -d' ' -f 1`
    cmd="sudo kill -9 $pid; sudo umount -f $mount_point"
fi

# verbose output
if [[ "$verbose" == "1" ]]
then
    echo "Init options:"
    echo " * action: $action"
    echo " * user: $user"
    echo " * pass: $pass"
    echo " * host: $host"
    echo " * hostname: $hostname"
    echo " * port: $port"
    echo " * dir: $dir"
    echo " * mount point: $mount_point"
    echo " * sshfs options: $options"

    echo ""
    echo "command to execute: $cmd"
fi

# execute the command
eval ${cmd}
code=$?

# report the result
if [[ "$code" != "0" ]]
then
    echo "command status code: $code"
    echo "something went wrong"
else
    if [[ "$verbose" == "1" ]]
    then
        echo "command status code: $code"
        if [[ "$action" == "up" ]]
        then
            echo "visit $mount_point to see the remote dir"
        fi
    fi
fi
