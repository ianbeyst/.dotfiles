FROM debian:buster-slim
ARG USERNAME
ARG USERID
ARG GROUPID
ARG SPOTIFY_REPO_KEY
ENV USER=$USERNAME
ENV BROWSER /usr/local/bin/browser
COPY browser.sh /usr/local/bin/browser
RUN addgroup --gid $GROUPID browsers
RUN adduser --ingroup browsers --disabled-password --uid $USERID --gecos "" $USER
RUN adduser $USER audio
RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
                                                      xauth \
                                                      zenity \
                                                      xclip \
                                                      gnupg2 \
                                                      curl \
                                                      ca-certificates \
                                                      libpulse0
RUN curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | apt-key add -
RUN echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
RUN apt-get update -y && apt-get install -y spotify-client
RUN apt-get -y --purge --auto-remove remove curl gnupg2
USER $USER
WORKDIR /home/$USER
CMD spotify > /home/$USER/.config/spotify/stdout 2> /home/$USER/.config/spotify/stderr

