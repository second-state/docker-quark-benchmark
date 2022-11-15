#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

COUNT=10
TIMEFORMAT=%R
LOGDIR=./log

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
}

function show_result {
    local name="$1"
    local logfile="$LOGDIR/$1"
    local min=$(sort -n "$logfile" | head -n 1)
    local max=$(sort -n "$logfile" | tail -n 1)
    local avg=$(awk 'function abs(x){return ((x < 0.0) ? -x : x)} {sum+=$0; sumsq+=($0)^2} END {mean = sum / NR; error = sqrt(abs(sumsq / NR - mean^2)); printf("%.3f", mean)}' $logfile)
    local sd=$(awk 'function abs(x){return ((x < 0.0) ? -x : x)} {sum+=$0; sumsq+=($0)^2} END {mean = sum / NR; error = sqrt(abs(sumsq / NR - mean^2)); printf("%.3f", error)}' $logfile)
    echo -e "$name\t$min\t$max\t$avg\t$sd"
}

[ -n "${1-}" ] && COUNT="$1"
rm -rf "$LOGDIR"
mkdir -p "$LOGDIR"

benchmark_quark_nodejs
benchmark_docker_nodejs

echo -e "name\t\t\tmin\tmax\tavg\tsd"
show_result benchmark_docker_nodejs
show_result benchmark_quark_nodejs
