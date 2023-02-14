# TODO

* config qbittorrent
* telegram theme
* use theme engine from https://github.com/SenchoPens/senixos
* update waybar
* FIX Seadrive
* Firejail all the things

## Tips:

* Copy sparse files

```bash
dd if=srcFile of=dstFile iflag=direct oflag=direct bs=64K conv=sparse
```

* swap on zfs zvol (on encrypted dataset only!)

```bash
zfs create -V 2G -b $(getconf PAGESIZE) -o logbias=throughput -o sync=always -o primarycache=metadata -o secondarycache=none -o com.sun:auto-snapshot=false -o compression=zle zroot/enc/swap
```