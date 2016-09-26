#!/usr/bin/env sh

export LC_ALL=C

Echo() {
	printf '%s\n' "$*"
}

Info() {
	Echo "$*"
}

Usage() {
	Echo "Usage: ${0##*/} [options] args-for-make
Available options are
  -q  quiet
  -n  Stop after ./configure, i.e. do not run make
  -jX Use -jX (currently $jarg)
  -r  Change also directory permissions to root (for fakeroot-ng)"
	exit ${1:-1}
}

Die() {
	Echo "${0##*/}: $1" >&2
	exit ${2:-1}
}

quiet=false
earlystop=false
use_chown=false
jarg='-j3'
enablepatch=false
configure_extra='--prefix=/usr'
OPTIND=1
while getopts 'qnrj:hH' opt
do	case $opt in
	q)	quiet=:;;
	n)	earlystop=:;;
	r)	use_chown=:;;
	j)	jarg=${OPTARG:+-j}$OPTARG;;
	'?')	exit 1;;
	*)	Usage 0;;
	esac
done
if [ $OPTIND -gt 1 ]
then	( eval '[ "$(( 0 + 1 ))" = 1 ]' ) >/dev/null 2>&1 && \
	eval 'shift "$(( $OPTIND - 1 ))"' || shift "`expr $OPTIND - 1`"
fi

$quiet && quietredirect='>/dev/null 2>&1' || quietredirect=

if $use_chown
then	ls /root >/dev/null 2>&1 && \
		Die "you should not really be root when you use -r" 2
	chown -R root:root .
fi

if ! test -e Makefile
then	if ! test -e configure || ! test -e Makefile.in
	then	Info "Running autotools..."
		eval "./autogen.sh -Werror $quietredirect" || Die "autogen failed"
	fi
	Info "Running ./configure" $configure_extra
	eval "./configure $configure_extra $quietredirect" || \
		Die 'configure failed'
fi
$earlystop && exit
Info "Making $*..."
command -v make >/dev/null 2>&1 || Die 'cannot find make'
if $quiet
then	exec make $jarg "$@" >/dev/null
else	exec make $jarg "$@"
fi
