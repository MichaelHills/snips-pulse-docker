#!/bin/sh

# Pulse config from https://askubuntu.com/a/976561 mixed in with the original snips docker run command
# from https://github.com/snipsco/snips-platform-documentation/wiki/6.--Miscellaneous#using-docker

while [ ! -e "/run/user/1001/pulse/native" ]; do
  sleep 2
done

/usr/bin/docker run -t --rm --name snips --log-driver none \
    --net="host" \
    -e PULSE_SERVER=unix:/run/user/1001/pulse/native \
    -v /run/user/1001/pulse/native:/run/user/1001/pulse/native \
    -v /home/mikeh/.config/pulse/cookie:/root/.config/pulse/cookie \
    --group-add $(getent group audio | cut -d: -f3) \
    -v /dev/snd:/dev/snd \
    -v /opt/snips/config/assistant:/usr/share/snips/assistant \
    --privileged \
    snips-pulse-docker --mqtt localhost:1883
