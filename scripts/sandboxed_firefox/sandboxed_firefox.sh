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
    docker build --tag ffsandbox \
                 --no-cache \
                 --rm \
                 --force-rm \
                 --build-arg USERNAME=$USER \
                 --build-arg USERID=$(id -u) \
                 --build-arg GROUPID=1000 \
                 .

    docker rmi $(docker images -f "dangling=true" -q)
else
    XSOCK=/tmp/.X11-unix
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
        xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTHORITY" nmerge -

        docker run \
               --rm \
               -d \
               --cap-drop="all" \
               --read-only \
               --pids-limit 400 \
               --memory="2g" \
               --cpus="4" \
               --device="/dev/dri:/dev/dri" \
               -e DISPLAY \
               -e XAUTHORITY \
               -v "$XSOCK":"$XSOCK":ro \
               -v "$XAUTHORITY":"$XAUTHORITY":ro \
               -v "$PROFILE_DIR":"$HOME/.mozilla":rw \
               -v "$DOWNLOADS_DIR":"$HOME/Downloads":rw \
               --tmpfs "$HOME/.cache" \
               --tmpfs "$HOME/.local" \
               --tmpfs "/tmp" \
               ffsandbox \
               > $PROFILE_DIR/container_id
    fi
fi

