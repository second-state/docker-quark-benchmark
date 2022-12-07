## Usage

- Install [Quark][] and [gVisor][].
- Start `dockerd` with `quark` and `runsc` runtime:

```
sudo dockerd -D -H unix:///tmp/dockerd/docker.sock \
    --data-root /tmp/dockerd/root \
    --pidfile /tmp/dockerd/docker.pid \
    --add-runtime quark=/usr/local/bin/quark \
    --add-runtime quark_d=/usr/local/bin/quark_d \
    --add-runtime runsc=/usr/local/bin/runsc
```

- Create and use docker context for Quark:

```
docker context create benchmark --docker host=unix:///tmp/dockerd/docker.sock
docker context use benchmark
```

- Run benchmarks:

```
./benchmark.sh <COUNT>
```

- Results (sec, lower is better):

```
name                    min     max     avg     sd
benchmark_docker_nodejs 20.854  21.268  20.930  0.058
benchmark_quark_nodejs  21.307  21.805  21.406  0.076
benchmark_gvisor_nodejs 21.332  21.927  21.474  0.091
```

## Node.js Benchmarks

Here we use [V8 benchmark suite version 7][v8-v7]. It contains the following benchmarks:

- `crypto.js`
    - Crypto related benchmarks.
- `deltablue.js`
    - A JavaScript implementation of the DeltaBlue constraint-solving algorithm.
- `earley-boyer.js`
    - Classic Scheme benchmarks translated to JavaScript.
- `navier-stokes.js`
    - 2D NavierStokes equations solver, heavily manipulates double precision arrays.
- `raytrace.js`
    - Ray tracer benchmark.
- `regexp.js`
    - Regular expression benchmark generated by extracting regular expression operations from 50 of the most popular web pages.
- `richards.js`
    - OS kernel simulation benchmark, originally written in BCPL.
- `splay.js`
    - Data manipulation benchmark that deals with splay trees and exercises the automatic memory management subsystem.
- Check [here](https://developers.google.com/octane/benchmark) for more information.

### Run the Node.js Benchmarks

- Run it seperately:

```
$ cd nodejs/v8-v7/
$ node crypto.js

Crypto: 46674
----
Score (version 7): 46674
```

- Run all the benchmarks (score, higher is better):

```
$ cd nodejs/v8-v7/
$ node v8-v7.js

Crypto: 46714
DeltaBlue: 83686
EarleyBoyer: 65225
NavierStokes: 43691
RayTrace: 63639
RegExp: 9799
Richards: 45886
Splay: 37323
----
Score (version 7): 43096
```

[Quark]: https://github.com/QuarkContainer/Quark
[gVisor]: https://github.com/google/gvisor
[v8-v7]: https://github.com/mozilla/arewefastyet/tree/master/benchmarks/v8-v7
