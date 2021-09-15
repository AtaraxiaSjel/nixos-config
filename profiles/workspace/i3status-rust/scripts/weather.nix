{ curl, config, ... }: ''
  #!/usr/bin/env bash
  ${curl}/bin/curl wttr.in/Volzhskiy\?format=3 | awk -F": " '{print $2}'
  if [[ $BLOCK_BUTTON == 1 ]]
  then
    ${config.defaultApplications.term.cmd} --hold -e "${curl}/bin/curl wttr.in"
  fi
''
