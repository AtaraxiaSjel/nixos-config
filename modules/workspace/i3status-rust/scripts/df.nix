{ bash, config, curl, ... }: with config.lib.base16.theme; ''
  #!/usr/bin/env bash
  echo '<span font="${iconFont}">folder</span>' `df -h / | tail -1 | awk '{print $4}'`iB
''
