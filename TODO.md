# TODO

* config.mainuser to extraArgs
* split modules to nixosModules and hmModules
* backup gitea with rustic
* fix waybar config (icons and catppuccin theme)


* move nginx config to respective profiles
* ocis confid and metadata backup (take zfs snapshot and backup it)
* grafana for all services
* move some profiles to modules (like vpn.nix)
* use sops for all occurrences of hashedPassword
* auto-import gpg keys
* config qbittorrent
* change writeShellScript and writeShellScriptBin to writeShellApplication
* remove aria2?
* move overlay and packages to root folder
* Change all 'latest' tags in docker container to digest: "statping/statping@sha256:aaaaa"
* or add cmd to all containers: "--pull=newer"
* fix global hotkeys for obs (use hyprland pass dispatcher)


https://github.com/catppuccin/rofi
https://github.com/catppuccin/waybar
https://github.com/catppuccin/base16
https://github.com/catppuccin/hyprlock
https://github.com/catppuccin/obs
https://github.com/catppuccin/spicetify
https://github.com/catppuccin/whoogle
https://github.com/catppuccin/dark-reader

## Tips:

* Copy sparse files

```bash
dd if=$1 of=$2 iflag=direct oflag=direct bs=64K conv=sparse
```

* swap on zfs zvol (on encrypted dataset only!)

```bash
zfs create -V 2G -b $(getconf PAGESIZE) -o logbias=throughput -o sync=always -o primarycache=metadata -o secondarycache=none -o com.sun:auto-snapshot=false -o compression=zle zroot/enc/swap
```

* disable offloading

```bash
ethtool --offload eth0 rx off tx off
```

```bash
eval "$(echo "gamemoderun mangohud %command%" | sed 's|BeamNG.drive.exe|BinLinux/BeamNG.drive.x64|g')" 2>&1 | tee $HOME/beamng.log
```

* reality url

vless://{uuid}@{server_ip}:{server_port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni={domain}&fp=chrome&pbk={pubkey}&sid={short_id}&type=tcp&headerType=none#SING-BOX-TCP

* sops keys

```bash
ssh-to-pgp -i $HOME/.ssh/id_rsa -o ~/nixos-config/keys/users/ataraxia.asc

ssh root@ip "cat /etc/ssh/ssh_host_rsa_key" | ssh-to-pgp -o ~/nixos-config/keys/hosts/hostname.asc
```