#! /usr/bin/env sh

run() {
	printf '%s\n' ">>> ${*}" >&2
	if ! "${@}"
	then	printf '%s\n' "failure" >&2
		exit 1
	fi
}

run mkdir -p config
run aclocal
run autoconf
run automake -af --copy
