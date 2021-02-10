#!/bin/sh
: << '---'

rsync options:
a:                Archive mode - various sane defaults.
H:                Preserve hard-links.
A:                Preserve ACLs.
X:                Preserve extended attributes.
x:                Don't cross file-system boundaries.
v:                Increase verbosity.
z:                Use compression.
P:                Show progress.
--numeric-ids:    Don't map uid/gid values to user/group names.
--delete:         Delete removed files on destination as well.

ssh options:
T:                Turn off pseudo-tty.
o Compression=no: Turn off SSH compression.
x:                Turn off X forwarding if it is on by default.

---

PROGNAME="$0"

usage() {
    cat << EOF >&2
Usage: $PROGNAME [-h] [-d <dest>]

-h       : Show this help.
-d <dest>: Backup the user's home directory to <dest>.

EOF
    exit 1
}



while getopts hd: o; do
    case "$o" in
        (h) usage;;
        (d) DEST="$OPTARG";;
        (*) usage
    esac
done
shift "$((OPTIND-1))"



if [ -z "$DEST" ]; then
    usage
fi



rsync -aHAXxvzP \
      --numeric-ids \
      --delete \
      -e 'ssh -T -x -o Compression=no -c aes128-gcm@openssh.com' \
      "$HOME"/ \
      "$DEST"

