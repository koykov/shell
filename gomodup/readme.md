# Go mod update tool

Go modules interactive update tool. By default, you need to execute many commands
consecutive to perform the update:

```shell
# for force update of all outdated modules
while IFS= read -r mod; do go get $mod; done <<< `go list -u -mod=mod -f '{{if (and (not (or .Main .Indirect)) .Update)}}{{.Path}}{{end}}' -m all`
go mod tidy
go mod vendor # if your project use vendor

# or for selective update
# - get list of outdated modules
go list -u -mod=mod -f '{{if (and (not (or .Main .Indirect)) .Update)}}{{.Path}}{{end}}' -m all
go get <mod0>
...
go get <modN>
go mod tidy
go mod vendor # if your project use vendor
```

That tool simplifies this process. Just run `gomodup` and you will see a selective dialog
where you can select modules to update, eg:

![Example](dialog.png)

Just select modules and press Enter.

If you want to execute tidy/vendor commands afterward, you may specify options `--tidy` and
`--vendor` (or short versions `-t` and `-v`).

If you want to update all outdated modules without interactive dialog, just specify option
`--force` (or short version `-f`).

Of course, you can combine options like `-ft` or `-tv` ...

## Installation

Just run `sudo ./install.sh`.

## Known `go list` problems

`gomodup` may fail with errors like
```shell
go list -m: loading module retractions for github.com/coreos/go-systemd@v0.0.0-20180511133405-39ca1b05acc7: no matching versions for query "latest"
go list -m: loading module retractions for gopkg.in/cheggaaa/pb.v1@v1.0.25: version "v1.0.29" invalid: go.mod has non-....v1 module path "github.com/cheggaaa/pb" at revision v1.0.29
go list -m: loading module retractions for gopkg.in/fsnotify.v1@v1.4.7: version "v1.5.1" invalid: go.mod has non-....v1 module path "github.com/fsnotify/fsnotify" at revision v1.5.1
```

This is a known `go list` problems and you need specify replace rules in `go.mod` file:
* `github.com/coreos/go-systemd => github.com/coreos/go-systemd/v22 v22.3.2`
* `gopkg.in/cheggaaa/pb.v1 => gopkg.in/cheggaaa/pb.v1 v1.0.25`
* `gopkg.in/fsnotify.v1 => gopkg.in/fsnotify.v1 v1.4.7`

Example:
```shell
replace github.com/coreos/go-systemd => github.com/coreos/go-systemd/v22 v22.3.2
```
or combinations like
```shell
replace (
    github.com/coreos/go-systemd => github.com/coreos/go-systemd/v22 v22.3.2
    gopkg.in/fsnotify.v1 => gopkg.in/fsnotify.v1 v1.4.7
)
```
