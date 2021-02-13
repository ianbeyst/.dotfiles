FROM debian:buster-slim
ARG USERNAME
ARG USERID
ARG GROUPID
ENV USER=$USERNAME
ENV BROWSER /usr/local/bin/browser
COPY slack-desktop-4.12.2-amd64.deb ./
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
                                                      libxkbfile1
RUN apt install -y --no-install-recommends ./slack-desktop-4.12.2-amd64.deb
COPY pulseaudio_docker_client_config /etc/pulse/client.conf
RUN rm slack-desktop-4.12.2-amd64.deb
USER $USER
WORKDIR /home/$USER
CMD slack > /home/io/.config/Slack/stdout 2> /home/io/.config/Slack/stderr

