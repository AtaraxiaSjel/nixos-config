# TODO

* config qbittorrent
* telegram theme
* use theme engine from https://github.com/SenchoPens/senixos
* update waybar
* Firejail all the things
* change writeShellScript and writeShellScriptBin to writeShellApplication
* add asserts to autoinstall module
* fix mime, fix xray (update on vps), fix aria2
* add updateScript to my packages
* move overlay and packages to root folder

## Tips:

* Copy sparse files

```bash
dd if=$1 of=$2 iflag=direct oflag=direct bs=64K conv=sparse
```

* swap on zfs zvol (on encrypted dataset only!)

```bash
zfs create -V 2G -b $(getconf PAGESIZE) -o logbias=throughput -o sync=always -o primarycache=metadata -o secondarycache=none -o com.sun:auto-snapshot=false -o compression=zle zroot/enc/swap
```