#!/bin/sh
ls -hlA --color=always --time-style=+" %Y-%m-%d %H:%M:%S " "$@" | tail -n +2
