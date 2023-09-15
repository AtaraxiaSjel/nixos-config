#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq python3
set -eu -o pipefail

kCONFIG="$(pwd)"
kNIXPKGS=$(nix flake metadata --json --inputs-from . nixpkgs | jq -r '.path')
kMAX_VER=`python $kCONFIG/scripts/find-latest-zfs-kernel.py $kNIXPKGS/pkgs/os-specific/linux/zfs/unstable.nix`

echo "found version: $kMAX_VER"

mkdir -p /tmp/nixpkgs/pkgs/os-specific/linux/kernel/
mkdir -p ./patches

cp $kNIXPKGS/pkgs/os-specific/linux/kernel/zen-kernels.nix /tmp/nixpkgs/pkgs/os-specific/linux/kernel/zen-kernels.nix
cd /tmp/nixpkgs
git init
git add -A
git commit -m "temp"

python $kCONFIG/scripts/update-zen.py lqx $kMAX_VER /tmp/nixpkgs/pkgs/os-specific/linux/kernel/zen-kernels.nix

git add -A
git diff --cached > $kCONFIG/patches/zen-kernels.patch
cd $kCONFIG
rm -rf /tmp/nixpkgs

echo "Complete!"
