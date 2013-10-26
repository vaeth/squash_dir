#!/usr/bin/env sh

export LC_ALL=C
umask 022

exec contrib/make.sh maintainer-clean
