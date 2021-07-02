#!/bin/bash

type=$1
bench=$2
if [ -z "$bench" ]; then
    bench=.
fi
if [ ! "$bench" == "." ]; then
    bench="^$bench\$"
fi

case $type in
    cpu) go test -o /tmp/cpuprofile.test -bench=$bench -benchmem -cpuprofile /tmp/cpuprofile.out ; go tool pprof /tmp/cpuprofile.out ;;
    mem) go test -o /tmp/memprofile.test -bench=$bench -benchmem -memprofile /tmp/memprofile.out ; go tool pprof /tmp/memprofile.out ;;
    *) echo "unknown type: $type" ;;
esac
