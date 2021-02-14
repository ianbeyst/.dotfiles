FROM debian:buster-slim
ARG USERNAME
ARG USERID
ARG GROUPID
ENV USER=$USERNAME
COPY google-chrome-stable_current_amd64.deb ./
RUN groupmod -g 27 --non-unique video
RUN addgroup --gid $GROUPID browsers
RUN adduser --ingroup browsers --disabled-password --uid $USERID --gecos "" $USER
RUN adduser $USER video
RUN adduser $USER audio
RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
                                                      xauth \
                                                      zenity \
                                                      xclip \
                                                      libxkbfile1 \
                                                      libpulse0
RUN apt install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb
COPY pulseaudio_docker_client_config /etc/pulse/client.conf
RUN rm google-chrome-stable_current_amd64.deb
USER $USER
WORKDIR /home/$USER
CMD google-chrome --disable-dev-shm-usage > /home/io/.config/google-chrome/stdout 2> /home/io/.config/google-chrome/stderr

