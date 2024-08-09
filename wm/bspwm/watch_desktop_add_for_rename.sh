#!/bin/sh

bspc subscribe desktop_add | while read -a msg ; do
  mon_id=${msg[1]}
  desk_id=${msg[2]}
  bspc desktop $desk_id -n $((`bspc query -D -m $mon_id --names | sort -n | tail -1` + 1)) 
done
