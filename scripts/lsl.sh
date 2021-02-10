#!/bin/sh
ls -hlA --color=always --hide-control-chars --time-style=+" %Y-%m-%d %H:%M:%S " "$@" | tail -n +2
