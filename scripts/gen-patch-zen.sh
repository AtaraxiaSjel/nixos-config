#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq python3
set -eu -o pipefail

kCONFIG="$(pwd)"
kNIXPKGS=$(nix flake archive --json --dry-run nixpkgs | jq -r '.path')
kMAX_VER=`python $kCONFIG/scripts/find-latest-zfs-kernel.py $kNIXPKGS/pkgs/os-specific/linux/zfs/default.nix`

echo $kMAX_VER
read -p "> Press any key to continue...1" -n 1 -r

mkdir -p /tmp/nixpkgs/pkgs/os-specific/linux/kernel/
mkdir -p ./patches

cp $kNIXPKGS/pkgs/os-specific/linux/kernel/zen-kernels.nix /tmp/nixpkgs/pkgs/os-specific/linux/kernel/zen-kernels.nix
cd /tmp/nixpkgs
git init
git add -A
git commit -m "temp"

read -p "> Press any key to continue...2" -n 1 -r

python $kCONFIG/scripts/update-zen.py zen $kMAX_VER /tmp/nixpkgs/pkgs/os-specific/linux/kernel/zen-kernels.nix

read -p "> Press any key to continue...3" -n 1 -r

git add -A
git diff --cached > $kCONFIG/patches/zen-kernels.patch
cd $kCONFIG
rm -rf /tmp/nixpkgs

echo "Complete!"