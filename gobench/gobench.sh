#!/bin/bash

type=$1
bench=$2
count=$3
time_=$4
if [ -z "$bench" ]; then
    bench=.
fi
if [ ! "$bench" == "." ]; then
    bench="^$bench\$"
fi
if [ -z "$count" ]; then
    count=1
fi
if [ -z "$time_" ]; then
    time_="1s"
fi

case $type in
    cpu) go test -o /tmp/cpuprofile.test -bench=$bench -benchmem -count=$count -benchtime=$time_ -cpuprofile /tmp/cpuprofile.out ; go tool pprof /tmp/cpuprofile.out ;;
    mem) go test -o /tmp/memprofile.test -bench=$bench -benchmem -count=$count -benchtime=$time_ -memprofile /tmp/memprofile.out ; go tool pprof /tmp/memprofile.out ;;
    *) echo "unknown type: $type" ;;
esac
