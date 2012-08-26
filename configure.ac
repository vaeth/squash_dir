# (C) Martin V\"ath <martin@mvath.de>

AC_INIT([squash_dir], [11.12])
AC_PREREQ([2.64])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_FILES([Makefile])
AM_MAINTAINER_MODE()
AM_INIT_AUTOMAKE()
m4_ifdef([AM_SILENT_RULES],
	[AM_SILENT_RULES([yes])])

AC_MSG_CHECKING([zsh completion])
AS_VAR_SET([ZSH_COMPLETION], ["${datadir}/zsh/site-functions"])
AC_ARG_WITH([zsh-completion],
	[AS_HELP_STRING([--with-zsh-completion=STR],
		[install zsh-completion file in directory STR])],
	[AS_CASE([${withval}],
		[/*], [AS_VAR_SET([ZSH_COMPLETION], ["${withval}"])],
		[no], [AS_VAR_SET([ZSH_COMPLETION], [])])])
AS_VAR_IF([ZSH_COMPLETION], [],
		[AC_MSG_RESULT([no])],
		[AC_MSG_RESULT([yes, into ${ZSH_COMPLETION}])])
AC_SUBST([ZSH_COMPLETION])

AC_OUTPUT()
