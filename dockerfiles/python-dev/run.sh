#!/bin/sh -e
SRC_DIR="$HOME/src/python-dev"
docker run \
       --rm \
       -it \
       --cap-drop="all" \
       --security-opt no-new-privileges \
       --pids-limit 500 \
       --memory="2g" \
       --memory-swap="6g" \
       --cpus="4" \
       -v "$SRC_DIR":$HOME/src \
       python-dev \
       /bin/bash

