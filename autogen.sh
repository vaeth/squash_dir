#! /usr/bin/env sh

run ()
{
	echo ">>> ${*}" 1>&2
	if ! "${@}"
	then	echo Failed 1>&2
		exit 1
	fi
}

run mkdir -p config
run aclocal
run autoconf
run automake -af --copy
