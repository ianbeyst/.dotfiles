FROM alpine:3.13
ARG USER_NAME
ARG IS_DOCKER
ENV USER=$USER_NAME
ENV IS_DOCKER=$IS_DOCKER
RUN apk update && apk upgrade && apk add alpine-conf openrc busybox-initscripts
COPY ./ /home/io/.dotfiles
RUN /home/io/.dotfiles/install_scripts/install_alpine.sh
USER io
WORKDIR /home/io
RUN /home/io/.dotfiles/scripts/setup.sh -d librem

