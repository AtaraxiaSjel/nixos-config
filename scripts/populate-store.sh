#!/usr/bin/env bash

while read p;
do
    nix-store --keep-going --ignore-unknown -r "$p" &
    # echo "$p"
    [ $( jobs | wc -l ) -ge $( nproc ) ] && wait
done < "$1"
wait
