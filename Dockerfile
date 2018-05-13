FROM snipsdocker/platform:arm-latest
RUN apt-get update && apt-get install -y pulseaudio
