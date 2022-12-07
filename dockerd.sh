#!/usr/bin/env bash
function run_dockerd {
  local runtime=$1
  if [[ -z "$runtime" ]]; then
    runtime=dockerd
  fi
  local tempspace=/tmp/$runtime.$USER
  echo "Starting dockerd at unix://$tempspace/docker.sock ..."
  case $runtime in
    gvisor)
      sudo dockerd -D -H unix://$tempspace/docker.sock \
        --data-root $tempspace/root \
        --pidfile $tempspace/docker.pid \
        --add-runtime runsc=/usr/local/bin/runsc
    ;;
    quark)
      sudo dockerd -D -H unix://$tempspace/docker.sock \
        --data-root $tempspace/root \
        --pidfile $tempspace/docker.pid \
        --add-runtime quark=/usr/local/bin/quark \
        --add-runtime quark_d=/usr/local/bin/quark_d
    ;;
    all|*)
      sudo dockerd -D -H unix://$tempspace/docker.sock \
        --data-root $tempspace/root \
        --pidfile $tempspace/docker.pid \
        --add-runtime quark=/usr/local/bin/quark \
        --add-runtime quark_d=/usr/local/bin/quark_d \
        --add-runtime runsc=/usr/local/bin/runsc
    ;;
  esac
}

run_dockerd $1
