#! /usr/bin/env nix-shell
#! nix-shell -i bash -p rsync ripgrep
rsync -amvxx \
  --dry-run \
  --no-links \
  --exclude '/tmp/*' \
  --exclude '/root/*' \
  / /persist \
  | rg -v '^skipping|/$'

rsync -amvxx \
  --dry-run \
  --no-links \
  --exclude 'ataraxia/.vscode/*' \
  /home/ataraxia /persist/home/ataraxia \
  | rg -v '^skipping|/$'
