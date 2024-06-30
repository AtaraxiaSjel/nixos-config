#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nixfmt-rfc-style

nix-instantiate --eval -E "builtins.fromJSON (builtins.readFile "$(realpath $1)")" | nixfmt
