#!/bin/sh

# Pulse config from https://askubuntu.com/a/976561 mixed in with the original snips docker run command
# from https://github.com/snipsco/snips-platform-documentation/wiki/6.--Miscellaneous#using-docker
/usr/bin/docker run -t --rm --name snips --log-driver none -p 9898:1883 \
    -e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
    -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
    -v ~/.config/pulse/cookie:/root/.config/pulse/cookie \
    --group-add $(getent group audio | cut -d: -f3) \
    -v /dev/snd:/dev/snd \
    -v /opt/snips/config/assistant:/usr/share/snips/assistant \
    --privileged \
    snips-pulse-docker
