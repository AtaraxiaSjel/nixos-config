{ bash, config, curl, ... }: ''
  #!/usr/bin/env bash
  echo '<span font="Material Icons">folder</span>' `df -h / | tail -1 | awk '{print $4}'`iB
''
