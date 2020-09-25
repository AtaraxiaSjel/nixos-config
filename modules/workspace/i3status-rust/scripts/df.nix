{ iconfont, ... }: ''
  #!/usr/bin/env bash
  echo '<span font="${iconfont} Solid"></span>' `zfs list -o space | head -2 | tail -1 | awk '{printf "%s / %s", $3, $2}'`
''
