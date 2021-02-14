#!/bin/sh -e

PROGNAME="$0"
SRCDIR=$(dirname $(readlink -f "$0"))



usage() {
    cat << EOF >&2
Usage: $PROGNAME [-h] [-b]

-h: Show this help.
-b: Build the docker image instead of running it

EOF
    exit 1
}



while getopts hb o; do
    case "$o" in
        (h) usage;;
        (b) BUILD="true";;
        (*) usage
    esac
done
shift "$((OPTIND-1))"



if [ "$BUILD" = "true" ]; then
    cd "$SRCDIR"
    cp "$SRCDIR/../../config/pulseaudio_docker_client_config" ./

    docker build --tag ffsandbox \
                 --no-cache \
                 --rm \
                 --force-rm \
                 --build-arg USERNAME=$USER \
                 --build-arg USERID=$(id -u) \
                 --build-arg GROUPID=1000 \
                 .

    rm pulseaudio_docker_client_config
    docker rmi $(docker images -f "dangling=true" -q)
else
    DOWNLOADS_DIR="$(xdg-user-dir DOWNLOAD)/$(date +%Y%m%d)"
    PROFILE_DIR="$HOME/.mozilla"

    mkdir -p "$DOWNLOADS_DIR"

    if [ -f "$PROFILE_DIR/container_id" ]; then
        CONTAINER_ID=$(cat "$PROFILE_DIR/container_id")
        CONTAINER_ID=$(docker ps -q -f id="$CONTAINER_ID")
    fi

    if [ "$CONTAINER_ID" ] && [ "$(docker ps -a | grep $CONTAINER_ID)" ]; then
        CONTAINER_RUNNING=$(docker container inspect -f '{{.State.Running}}' "$CONTAINER_ID")
    fi

    if [ "$CONTAINER_RUNNING" == "true" ]; then
        docker exec -d $CONTAINER_ID firefox
    else
        XSOCK=/tmp/.X11-unix
        xauth -b nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -b -f "$XAUTHORITY" nmerge -

        PULSE_SOCKET="/tmp/pulseaudio.socket"
        if [ ! -S "$PULSE_SOCKET" ]; then
            pactl load-module module-native-protocol-unix socket="$PULSE_SOCKET"
        fi

        docker run \
               --rm \
               -d \
               --cap-drop="all" \
               --security-opt no-new-privileges \
               --read-only \
               --pids-limit 500 \
               --memory="2g" \
               --memory-swap="6g" \
               --cpus="4" \
               --device="/dev/dri:/dev/dri" \
               -e DISPLAY \
               -e XAUTHORITY \
               -e PULSE_SERVER="unix:$PULSE_SOCKET" \
               -e PULSE_COOKIE="/tmp/pulseaudio.cookie" \
               -v "$XSOCK":"$XSOCK":ro \
               -v "$XAUTHORITY":"$XAUTHORITY":ro \
               -v "$PULSE_SOCKET":"$PULSE_SOCKET":ro \
               -v "$PROFILE_DIR":"$HOME/.mozilla":rw \
               -v "$DOWNLOADS_DIR":"$HOME/Downloads":rw \
               --tmpfs "$HOME/.cache" \
               --tmpfs "$HOME/.local" \
               --tmpfs "/tmp" \
               ffsandbox \
               > $PROFILE_DIR/container_id
    fi
fi

