#!/usr/bin/env bash
set -Eeuo pipefail
# Source: https://github.com/tianon/dockerfiles/commit/a6fd50185d232c0ce9d38091564ceb0dc42d8b93

url="$*"

if
	zenity --question \
		--no-wrap \
		--no-markup \
		--text=$'Browser requested for:\n\n'"$url"$'\n\nCopy URL to clipboard?'
then
	xclip -selection clipboard <<<"$url"
fi
