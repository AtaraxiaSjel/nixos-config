{ iconfont, light, config, ... }: ''
  case $BLOCK_BUTTON in
       4) sudo ${light}/bin/light -A 5;;
       5) sudo ${light}/bin/light -U 5;;
  esac
  LIGHT=`${light}/bin/light | cut -f 1 -d '.'`
  if [[ $LIGHT -lt 33 ]]
  then
    icon=
  else
    if [[ $LIGHT -lt 66 ]]
    then
      icon=
    else
      icon=
    fi
  fi
  echo "<span font='${iconfont}'>$icon</span> $LIGHT"
''
