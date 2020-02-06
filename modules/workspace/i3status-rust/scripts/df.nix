{ ... }: ''
#!/usr/bin/env bash
echo $(sudo btrfs fi usage / | grep "Free" | awk '{print $3}')
''