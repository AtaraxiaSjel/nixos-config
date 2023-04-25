# TODO

* config qbittorrent
* telegram theme
* use theme engine from https://github.com/SenchoPens/base16.nix (?)
* fix waybar config
* Firejail all the things (maybe not...)
* change writeShellScript and writeShellScriptBin to writeShellApplication
* add asserts to autoinstall module
* fix mime, fix aria2
* add updateScript to my packages
* move overlay and packages to root folder
* Change all 'latest' tags in docker container to digest: "statping/statping@sha256:aaaaa"
* or add cmd to all containers: "--pull=newer"
* fix global hotkeys for obs (use hyprland pass dispatcher)

## Tips:

* Copy sparse files

```bash
dd if=$1 of=$2 iflag=direct oflag=direct bs=64K conv=sparse
```

* swap on zfs zvol (on encrypted dataset only!)

```bash
zfs create -V 2G -b $(getconf PAGESIZE) -o logbias=throughput -o sync=always -o primarycache=metadata -o secondarycache=none -o com.sun:auto-snapshot=false -o compression=zle zroot/enc/swap
```