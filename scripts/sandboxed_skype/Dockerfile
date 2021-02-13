FROM debian:buster-slim
ARG USERNAME
ARG USERID
ARG GROUPID
ENV USER=$USERNAME
ENV BROWSER /usr/local/bin/browser
COPY browser.sh /usr/local/bin/browser
RUN groupmod -g 27 --non-unique video
RUN addgroup --gid $GROUPID browsers
RUN adduser --ingroup browsers --disabled-password --uid $USERID --gecos "" $USER
RUN adduser $USER video
RUN adduser $USER audio
RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
                                                      xauth \
                                                      zenity \
                                                      xclip \
                                                      libpulse0 \
                                                      procps
COPY skypeforlinux-64.deb ./
RUN apt install -y --no-install-recommends ./skypeforlinux-64.deb
RUN rm skypeforlinux-64.deb
COPY pulseaudio_docker_client_config /etc/pulse/client.conf
COPY skype_entrypoint.sh /home/$USER/.local/bin/skype
USER $USER
WORKDIR /home/$USER
CMD /home/$USER/.local/bin/skype

