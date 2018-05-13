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

The TTS command is currently coming out as crackling for me on Odroid C2 with Hifi Shield 2. Still trying to figure it out, but the aplay works!
