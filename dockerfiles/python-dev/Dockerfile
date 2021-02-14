FROM debian:buster-slim
ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
ENV USER=$USER_NAME
RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
                                                      neovim \
                                                      tmux \
                                                      htop \
                                                      python3 \
                                                      python3-pip \
                                                      bash-completion \
                                                      git \
                                                      wget \
                                                      gnupg2
RUN addgroup --gid $GROUP_ID developers
RUN adduser --ingroup developers --disabled-password --uid $USER_ID --gecos "" $USER
COPY ./ /home/$USER/.dotfiles
RUN chown -R $USER /home/$USER/.dotfiles
USER $USER
WORKDIR /home/$USER
RUN /home/$USER/.dotfiles/scripts/setup.sh -d docker

