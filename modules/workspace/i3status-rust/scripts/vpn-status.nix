{ curl, ... }: ''
#!/usr/bin/env bash
API="$(${curl}/bin/curl https://am.i.mullvad.net/connected)"
if [[ $(echo "$API" | awk -F'[ ()]+' '{print $6}') = 'server' ]]; then
  echo $(echo "$API" | awk -F'[ ()]+' '{print $7}')
else
  echo 'Not connected'
fi
''