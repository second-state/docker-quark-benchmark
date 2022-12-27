#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

trap - SIGINT SIGTERM EXIT

[ -z "${1-}" ] && echo "Usage: $0 <container_name>" && exit 1
CONTAINER_NAME="$1"

# wait until container is start
while [[ $(docker inspect -f {{.State.Running}} "$CONTAINER_NAME") != "true" ]]
do
    sleep 1
done

while true
do
    mem=$(docker stats --no-stream --format '{{.MemUsage}}' "$CONTAINER_NAME" | awk '{print $1}')
    echo "memory_usage: $mem"
    sleep 1
done
