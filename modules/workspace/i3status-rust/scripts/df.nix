{ iconfont, ... }: ''
  #!/usr/bin/env bash
  echo '<span font="${iconfont} Solid"></span>' `df -BM / | tail -1 | awk '{printf "%.2fGiB / %.2fGiB", $3/1024, $2/1024}'`
''
