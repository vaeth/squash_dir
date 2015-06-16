#!/usr/bin/env sh

Echo() {
	printf '%s\n' "$*" >&2
}

Die() {
	Echo "$*"
	exit 1
}

Run() {
	Echo ">>> $*"
	"$@" || Die 'failure'
}

Run mkdir -p -m 755 config
Run aclocal
Run autoconf
Run automake -a --copy "$@"
