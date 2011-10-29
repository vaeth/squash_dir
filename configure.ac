# Copyright (c)
#  Martin Väth <martin@mvath.de>

AC_INIT([squash_dir], [10.2])
AC_PREREQ([2.64])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_FILES([Makefile])
AM_MAINTAINER_MODE()
AM_INIT_AUTOMAKE()
m4_ifdef([AM_SILENT_RULES],
	[AM_SILENT_RULES([yes])])

AC_ARG_ENABLE([squashfs_tools_patch],
	[AS_HELP_STRING([--enable-squashfs-tools-patch],
		[patch squashfs-tools to output progress to stderr])],
	[AS_CASE(["${enableval}"],
		[yes], [AS_VAR_SET([squashfs_tools_patch], [:])],
		[no], [AS_VAR_SET([squashfs_tools_patch], [false])],
		[AC_MSG_ERROR([bad value ${enableval} for --enable-squashfs-tools-patch])])],
	[AS_VAR_SET([squashfs_tools_patch], [false])])
AM_CONDITIONAL([SQUASHFS_TOOLS_PATCH],
	[${squashfs_tools_patch}])

AC_ARG_WITH([decompress],
	[AS_HELP_STRING([--with-decompress=STR],
		[use STR for decompression. If not set or empty, no compression is assumed])],
	[AS_VAR_SET([DECOMPRESS], ["${withval}"])],
	[AS_VAR_SET([DECOMPRESS], [])])
AS_IF([test x"${DECOMPRESS}" = x""],
	[AS_VAR_SET([DECOMPRESS], [cat --])])
AC_SUBST([DECOMPRESS])

AC_PROG_SED()

AC_OUTPUT()
