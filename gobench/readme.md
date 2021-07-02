# Go bench

Handy commands to run go bench command and inspect profile result.

Provide 3 commands: `gobench`, `cpubench`, `membench`.

## Usage

Run all tests in the package.
```shell
cd path/to/go/package/with/tests
gobench mem
```

Run certain test
```shell
cd path/to/go/package/with/tests
gobench cpu BenchmarkFeatureX
```

Commands `cpubench` and `membench` is an aliases for `gobench cpu` and `gobench mem`.
