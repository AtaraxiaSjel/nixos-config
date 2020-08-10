{ curl, iconfont, ... }: ''
#!/usr/bin/env bash
API="$(${curl}/bin/curl https://am.i.mullvad.net/connected)"
if [[ $(echo "$API" | awk -F'[ ()]+' '{print $6}') = 'server' ]]; then
  echo '<span font="${iconfont} Solid"></span>' `(echo "$API" | awk -F'[ ()]+' '{print $7}')`
else
  echo '<span font="${iconfont} Solid"></span>' 'Not connected'
fi
''