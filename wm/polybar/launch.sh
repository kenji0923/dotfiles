#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# main_monitor=("HDMI1" "rdp0")
main_monitor=HDMI1

# Launch Polybar, using default config location ~/.config/polybar/config
for m in $(polybar -M | cut -d ":" -f 1); do
  # if [[ $(echo ${main_monitor[@]} | grep -Fw $m) ]]; then
  if [ $m = $main_monitor ]; then
    bar=main
  else
    bar=sub
  fi
  MONITOR=$m polybar --reload $bar &
  # pgrep -f "polybar --reload $bar" > /tmp/polybar_$bar@$DISPLAY
done

echo "Polybar launched..."
