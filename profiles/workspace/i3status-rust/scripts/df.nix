{ iconfont, ... }: ''
  #!/usr/bin/env bash
  echo '<span font="${iconfont} Solid"></span>' `(doas btrfs fi usage / | head -n7 | tail -n1 | awk '{print $3}')`
''
