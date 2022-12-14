#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

COUNT=10
TIMEFORMAT=%R
LOGDIR=./log

function benchmark_runc_nodejs {
    local image_name=$FUNCNAME
    local logfile="$LOGDIR/$image_name"
    rm -f "$logfile"
    docker buildx build -t "$image_name" -f docker/nodejs.Dockerfile . >&/dev/null
    for i in $(seq 1 $COUNT); do
        date +"start: %s.%3N"
        docker run --rm "$image_name"
        date +"end: %s.%3N"
    done >"$logfile" 2>&1
    docker rmi "$image_name" >&/dev/null
}

function benchmark_quark_nodejs {
    local image_name=$FUNCNAME
    local logfile="$LOGDIR/$image_name"
    rm -f "$logfile"
    docker buildx build -t "$image_name" -f docker/nodejs.Dockerfile . >&/dev/null
    for i in $(seq 1 $COUNT); do
        date +"start: %s.%3N"
        docker run --rm --runtime quark "$image_name"
        date +"end: %s.%3N"
    done >"$logfile" 2>&1
    docker rmi "$image_name" >&/dev/null
}

function benchmark_gvisor_nodejs {
    local image_name=$FUNCNAME
    local logfile="$LOGDIR/$image_name"
    rm -f "$logfile"
    docker buildx build -t "$image_name" -f docker/nodejs.Dockerfile . >&/dev/null
    for i in $(seq 1 $COUNT); do
        date +"start: %s.%3N"
        docker run --rm --runtime runsc "$image_name"
        date +"end: %s.%3N"
    done >"$logfile" 2>&1
    docker rmi "$image_name" >&/dev/null
}

function benchmark_wasmedge_quickjs {
    local image_name=$FUNCNAME
    local logfile="$LOGDIR/$image_name"
    rm -f "$logfile"
    docker buildx build --platform=wasi/wasm -t "$image_name" -f docker/quickjs.Dockerfile . >&/dev/null
    for i in $(seq 1 $COUNT); do
        date +"start: %s.%3N"
        docker run --rm \
            --runtime io.containerd.wasmedge.v1 \
            --platform wasi/wasm \
            "$image_name"
        date +"end: %s.%3N"
    done >"$logfile" 2>&1
    docker rmi "$image_name" >&/dev/null
}

[ -n "${1-}" ] && COUNT="$1"
rm -rf "$LOGDIR"
mkdir -p "$LOGDIR"

benchmark_runc_nodejs
benchmark_quark_nodejs
benchmark_gvisor_nodejs
benchmark_wasmedge_quickjs

./utils/calculate.py
