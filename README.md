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
./benchmark.sh <COUNT>
```

- Results:

```
name                    min     max     avg     sd
benchmark_docker_nodejs 20.915  21.058  20.978  0.041
benchmark_quark_nodejs  21.363  21.535  21.434  0.049
```

[Quark]: https://github.com/QuarkContainer/Quark
