# run_rocksmith_linux

In November 2020 some guy published on Reddit
[a guide to running Rocksmith on Linux using Jack](https://www.reddit.com/r/linux_gaming/comments/jmediu/guide_for_setup_rocksmith_2014_steam_no_rs_cable/).
This method worked great for me - the game is playable, with low latency, and has less issues than under Windows.
But I had several problems, in particular:

* The screensaver was blocking the screen while playing the guitar.
* The Jack input interface had to be created for the USB cable each time, and the ALSA device number was different each time.
* The Jack inputs had to be connected to Rocksmith manually each time.
* The `RS_ASIO.ini` file had to be changed if I wanted to play in multiplayer mode with multiple interfaces.

This script was created to fix those problems.

## Usage

Modify the `SOUND_DEVICE_REGEX` variable in the script to match the name of your interface in ALSA.
You can find the name using `arecord -l`.

Then set the launch options for Rocksmith 2014 in Steam to:

```
/path/to/run_rocksmith.sh %command%
```

And you're good to go.

## Caveats

The script uses `gnome-session-inhibit` to block the screensaver, which is GNOME-specific.
