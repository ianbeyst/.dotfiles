FROM alpine:edge
ARG USERNAME
ARG USERID
ARG GROUPID
ENV USER=$USERNAME
RUN apk update && apk upgrade && apk add firefox \
                                         xauth \
                                         adwaita-gtk2-theme \
                                         adwaita-icon-theme \
                                         font-noto-all \
                                         font-noto-cjk \
                                         font-noto-cjk-extra \
                                         ttf-dejavu
RUN addgroup -g $GROUPID -S browsers && adduser -G browsers -S -D -u $USERID $USER
USER $USER
WORKDIR /home/$USER
CMD firefox > /home/$USER/.mozilla/stdout 2> /home/$USER/.mozilla/stderr

