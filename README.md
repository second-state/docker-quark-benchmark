## Usage

- Install [Quark][].
- Start `dockerd` with `quark` runtime:

```
sudo dockerd -D -H unix:///tmp/quark/docker.sock \
    --data-root /tmp/quark/root \
    --pidfile /tmp/quark/docker.pid \
    --add-runtime quark=/usr/local/bin/quark \
    --add-runtime quark_d=/usr/local/bin/quark_d
```

- Create and use docker context for Quark:

```
docker context create quark --docker host=unix:///tmp/quark/docker.sock
docker context use quark
```

- Run benchmarks:

```
./benchmark.sh
```

- Results:

```
benchmark_quark_nodejs 21.383(0.093)
benchmark_docker_nodejs 20.986(0.043)
```

[Quark]: https://github.com/QuarkContainer/Quark
