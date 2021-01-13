#!/bin/bash

# Locate the Rocksmith directory
#for ARG in "$@"; do
#    if [[ `basename "$ARG"` = "Rocksmith2014.exe" ]]; then
#        PATH=`dirname "$ARG"`
#    fi
#done

# Find USB interfaces
SOUND_DEVICE_REGEX="USB PnP Sound Device"
CARDS=`arecord -l | grep "^card " | grep "\[$SOUND_DEVICE_REGEX\]" | sed "s/^card \([0-9]*\): .*$/\1/"`

# Kill children processes on script exit
trap 'kill $(jobs -p)' EXIT

# Spawn JACK inputs
for X in $CARDS; do
    alsa_in -d hw:$X,0 -j USB$X &
done

# Inhibit screen-saver
gnome-session-inhibit --inhibit-only &

# Run Rocksmith
PROTON_NO_D3D10=1 PROTON_NO_D3D11=1 PROTON_NO_ESYNC=1 "$@" &

STEAM_PID=$!

sleep 10

# Connect Rocksmith to USB interfaces
jack_disconnect system:capture_1 Rocksmith2014:in_1
jack_disconnect system:capture_2 Rocksmith2014:in_2
N=1
for X in $CARDS; do
    jack_connect USB$X:capture_1 Rocksmith2014:in_$N
    let N=N+1
done

# Wait until Rocksmith dies
wait $STEAM_PID

