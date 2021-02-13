FROM alpine:edge
ARG USERNAME
ARG USERID
ARG GROUPID
ENV USER=$USERNAME
ENV MOZ_X11_EGL=1
ENV MOZ_WEBRENDER=1
RUN apk update && apk upgrade && apk add firefox \
                                         xauth \
                                         adwaita-gtk2-theme \
                                         adwaita-icon-theme \
                                         font-noto-all \
                                         font-noto-cjk \
                                         font-noto-cjk-extra \
                                         ttf-dejavu \
                                         libva-intel-driver \
                                         mesa-gl \
                                         mesa-egl \
                                         mesa-gles \
                                         ffmpeg-libs \
                                         mesa-dri-gallium \
                                         libpulse
COPY pulseaudio_docker_client_config /etc/pulse/client.conf
RUN addgroup -g $GROUPID -S browsers && adduser -G browsers -S -D -u $USERID $USER && addgroup $USER video && addgroup $USER audio
USER $USER
WORKDIR /home/$USER
CMD firefox > /home/$USER/.mozilla/stdout 2> /home/$USER/.mozilla/stderr

