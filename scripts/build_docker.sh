#!/bin/sh -e
PROGNAME="$0"
SRCDIR=$(dirname $(readlink -f "$0"))
DFDIR="$SRCDIR/.."

usage() {
    cat << EOF >&2
Usage: $PROGNAME [-h] [-i <image name>] [-u <username> ] [-g <group id>]

-h:              Show this help.
-i <image name>: Build the specified docker image
-u <username>:   The username of the unprivileged user in the container
-g <group id>:   The group ID (GID) of the unprivileged user in the container

EOF
    exit 1
}


USER_NAME="$USER"
USER_ID=$(id -u)
GROUP_ID=$(id -g)

while getopts hi:u:g: o; do
    case "$o" in
        (h) usage;;
        (i) IMAGE_NAME="$OPTARG";;
        (u) USER_NAME="$OPTARG";;
        (g) GROUP_ID="$OPTARG";;
        (*) usage
    esac
done
shift "$((OPTIND-1))"

if [ -z "$IMAGE_NAME" ]; then
    usage
fi


docker build --tag "$IMAGE_NAME" \
             --build-arg USER_NAME="$USER_NAME" \
             --build-arg USER_ID="$USER_ID" \
             --build-arg GROUP_ID="$GROUP_ID" \
             --build-arg IS_DOCKER=true \
             -f "$DFDIR/dockerfiles/$IMAGE_NAME/Dockerfile" \
             "$DFDIR"

