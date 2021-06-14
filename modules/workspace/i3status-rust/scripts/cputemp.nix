{ iconfont, ... }: ''
  #!/usr/bin/env bash
  echo `sensors | egrep Package | awk '{print $4}'`
''
