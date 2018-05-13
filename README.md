# Snips running in Docker using Pulseaudio

If you are using snips in a desktop environment that uses pulseaudio to share/mix your sound devices, then you'll probably want the snips beeps/tts on pulse as well. Especially if dmix is not supported on your system.

This repo is an example of how to extend `snipsdocker/platform` with pulseaudio support. It is assumed you have setup pulseaudio with your default sink and source devices and those are the ones you want to use with snips.

## Running the docker image

Build the docker image
```
docker build -t snips-pulse-docker .
```

and run it
```
./run-snips.sh
```

Then test it out in another terminal
```
docker exec -it snips aplay /usr/share/snips/assistant/custom_dialogue/sound/start_of_input.wav
docker exec -it snips mosquitto_pub -h localhost -p 1883 -t hermes/tts/say -m '{"siteId":"default","text":"hello how are you"}'
```

## Issues

With default pulse configuration, sound coming out of `snips-audio-server` comes out crackling. Both TTS and the hotword beeps. However I did finally fix that by tuning my pulse config, details below. Note this is specifically for my Odroid C2 + Hifi Shield 2 (card 1) setup using PS3 eye mic (card 2) and ignoring the HDMI sound (card 0).

First up `/etc/asound.conf`. Specifically the rate / format / channels combo was necessary for me to get sound working from the docker container, but not from `snips-audio-server`.

```
pcm.!default {
  type asym
  playback.pcm {
    type plug
    slave {
      pcm "hw:1,0"
      rate 48000
      format "S16_LE"
      channels 2
    }
  }
  capture.pcm {
    type plug
    slave.pcm "hw:2,0"
  }
}

ctl.!default {
  type hw
  card 1
}
```

Next up was modifying pulse configuration. I had noticed logs in pulseaudio along the lines of
```
(   9.856|   0.000) D: [pulseaudio] protocol-native.c: Early requests mode enabled, configuring sink latency to minreq.
(   9.856|   0.000) D: [pulseaudio] protocol-native.c: Requested latency=20.00 ms, Received latency=92.88ms
```
and so decided to go mess with buffer sizes.

This guide https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Setting_the_default_fragment_number_and_buffer_size_in_PulseAudio was very useful.

I modified `/etc/pulse/default.pa` to add `tsched=0`
```
load-module module-udev-detect tsched=0
```

then modified `/etc/pulse/daemon.conf`
```
default-sample-format = s16le
default-sample-rate = 48000
default-sample-channels = 2

default-fragments = 5
default-fragment-size-msec = 4
```

The first three were to match my `asound.conf` and the latter two were to match the requested 20ms latency. And that's it, I could now hear sound clearly from `snips-audio-server`.

