#!/bin/bash

mod=$1
if [[ -z "$mod" ]]; then
  echo "mod name is required"
  exit 1
fi
src="$GOPATH/src/$mod"
if [[ ! -d "$src" ]]; then
  echo "source doesn't exists: $src"
  exit 1
fi

dst="$PWD/vendor/$mod"

if [[ -d "$dst" ]]; then
  rm -rf "$dst"
fi

mkdir -p "$(dirname "$dst")"
echo -n "symlink $src -> $dst ... "
ln -s "$src" "$dst"
echo "done"
