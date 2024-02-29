#!/bin/bash

type=$1
bench=$2
shift;
if [ -z "$bench" ]; then
    bench=.
else
    shift;
fi

count=""
duration=""
timeout=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--count) count="$2"; shift;;
        -d|--duration) duration="$2"; shift;;
        -t|--timeout) timeout="$2"; shift;;
        *) arg="$1"; shift;;
    esac;
    shift;
done
if [ -z "$count" ]; then
    count=1
fi
if [ -z "$duration" ]; then
    duration="1s"
fi
if [ -z "$timeout" ]; then
    timeout="10m"
fi

case $type in
    cpu) go test -o /tmp/cpuprofile.test -bench=$bench -benchmem -count=$count -benchtime=$duration -timeout=$timeout -cpuprofile /tmp/cpuprofile.out ; go tool pprof /tmp/cpuprofile.out ;;
    mem) go test -o /tmp/memprofile.test -bench=$bench -benchmem -count=$count -benchtime=$duration -timeout=$timeout -memprofile /tmp/memprofile.out ; go tool pprof /tmp/memprofile.out ;;
    *) echo "unknown type: $type" ;;
esac
