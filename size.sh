#!/usr/bin/env bash
nix-store -q --size $(nix-store -qR $(readlink -e $1) ) | \
awk '{ a+=$1 } END { print a }' | \
numfmt --to=iec-i
