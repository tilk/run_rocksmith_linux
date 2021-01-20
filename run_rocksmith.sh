#!/bin/bash

WINEASIO=/usr/lib/i386-linux-gnu/wine/wineasio.dll.so
SOUND_DEVICE_REGEX="USB PnP Sound Device"

# Locate the Rocksmith directory
for ARG in "$@"; do
    if [[ `basename -- "$ARG"` = "Rocksmith2014.exe" ]]; then
        RPATH=`dirname -- "$ARG"`
    fi
done

# Locate the Proton directory
for ARG in "$@"; do
    if [[ `basename -- "$ARG"` = "proton" ]]; then
        PPATH=`dirname -- "$ARG"`
    fi
done

# Copy wineasio library if not present
if [[ ! -f "$PPATH/dist/lib/wine/wineasio.dll.so" ]]; then
    cp $WINEASIO "$PPATH/dist/lib/wine/"
fi

# Find USB interfaces
CARDS=(`arecord -l | grep "^card " | grep "\[$SOUND_DEVICE_REGEX\]" | sed "s/^card \([0-9]*\): .*$/\1/"`)

# Update RS_ASIO.ini for multiplayer
if [[ ${#CARDS[@]} > 1 ]]; then
    ISEMI=";"; OSEMI=""
else
    ISEMI=""; OSEMI=";"
fi
sed -i~ "\$!N;/\\[Asio\\.Input\\.1\\]/s/\\n${ISEMI}Driver/\\n${OSEMI}Driver/;P;D" "$RPATH/RS_ASIO.ini"

# Kill children processes on script exit
trap 'kill $(jobs -p)' EXIT

# Spawn JACK inputs
for X in ${CARDS[@]}; do
    alsa_in -c 1 -d hw:$X,0 -j USB$X &
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
for X in ${CARDS[@]}; do
    jack_connect USB$X:capture_1 Rocksmith2014:in_$N
    let N=N+1
done

# Wait until Rocksmith dies
wait $STEAM_PID

