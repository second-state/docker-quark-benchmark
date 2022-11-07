#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

COUNT=10
TIMEFORMAT=%R
LOGDIR=./log

rm -rf "$LOGDIR"
mkdir -p "$LOGDIR"

function mean_error {
    local logfile="$1"
    awk 'function abs(x){return ((x < 0.0) ? -x : x)} {sum+=$0; sumsq+=($0)^2} END {mean = sum / NR; error = sqrt(abs(sumsq / NR - mean^2)); printf("%.3f(%.3f)", mean, error)}' $logfile
}

function benchmark_docker_nodejs {
    local image_name=$FUNCNAME
    local logfile="$LOGDIR/$image_name"
    rm -f "$logfile"
    docker build -t "$image_name" -f docker/nodejs.Dockerfile . >&/dev/null
    for i in $(seq 1 $COUNT); do
        time docker run --rm "$image_name" >&/dev/null
    done 2>"$logfile"
    docker rmi "$image_name" >&/dev/null
    echo "$image_name $(mean_error $logfile)"
}

function benchmark_quark_nodejs {
    local image_name=$FUNCNAME
    local logfile="$LOGDIR/$image_name"
    rm -f "$logfile"
    docker build -t "$image_name" -f docker/nodejs.Dockerfile . >&/dev/null
    for i in $(seq 1 $COUNT); do
        time docker run --rm --runtime quark "$image_name" >&/dev/null
    done 2>"$logfile"
    docker rmi "$image_name" >&/dev/null
    echo "$image_name $(mean_error $logfile)"
}

benchmark_quark_nodejs
benchmark_docker_nodejs
