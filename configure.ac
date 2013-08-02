# (C) Martin V\"ath <martin@mvath.de>

AC_INIT([squash_dir], [12.10])
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
		[/*], [AS_VAR_COPY([ZSH_COMPLETION], [withval])],
		[no], [AS_VAR_SET([ZSH_COMPLETION], [])])])
AS_VAR_IF([ZSH_COMPLETION], [],
		[AC_MSG_RESULT([no])],
		[AC_MSG_RESULT([yes, into ${ZSH_COMPLETION}])])
AC_SUBST([ZSH_COMPLETION])

AC_MSG_CHECKING([for ORDER default])
AS_VAR_SET([order], ["aufs overlayfs unionfs-fuse funionfs unionfs"])
AC_ARG_WITH([first-order],
	[AS_HELP_STRING([--with-first-order=STR],
		[use STR as first entry in ORDER default])],
	[AS_CASE([${withval}],
		[overlayfs], [AS_VAR_SET([order],
			["overlayfs aufs unionfs-fuse funionfs unionfs"])],
		[aufs], [AS_VAR_SET([order],
			["aufs overlayfs unionfs-fuse funionfs unionfs"])],
		[unionfs-fuse], [AS_VAR_SET([order],
			["unionfs-fuse overlayfs aufs funionfs unionfs"])],
		[funionfs], [AS_VAR_SET([order],
			["funionfs overlayfs aufs unionfs-fuse unionfs"])],
		[unionfs], [AS_VAR_SET([order],
			["unionfs overlayfs aufs unionfs-fuse funionfs"])])])
AC_ARG_WITH([order],
	[AS_HELP_STRING([--with-order=STR],
		[use STR as ORDER default])],
	[AS_CASE([${withval}],
		[*overlay*|*aufs*|*union*],
			[AS_VAR_COPY([order], [withval])])])
AC_MSG_RESULT([${order}])

AC_PROG_SED()
AS_IF([["${SED}" -e "s/[-a-z ]*  ([*])/${order}  (*)/" README >|patching.tmp]],
	[],
	[AC_MSG_ERROR(["sed for README failed"])])
AS_IF([diff README patching.tmp],
	[],
	[AC_MSG_NOTICE([patching README])
	AS_IF([cat patching.tmp >|README],
		[],
		[AC_MSG_ERROR(["cannot patch README"])])])
AS_IF([["${SED}" -e "s/ORDER-[-a-z ]*/ORDER-${order}/" init.d/squash_dir >|patching.tmp]],
	[],
	[AC_MSG_ERROR(["sed for init.d/squash_dir failed"])])
AS_IF([diff init.d/squash_dir patching.tmp],
	[],
	[AC_MSG_NOTICE([patching init.d/squash_dir])
	AS_IF([cat patching.tmp >|init.d/squash_dir],
		[],
		[AC_MSG_ERROR(["cannot patch init.d/squash_dir"])])])
AS_IF([["${SED}" -e "s/ORDER-[-a-z ]*/ORDER-${order}/" conf.d/squash_dir >|patching.tmp]],
	[],
	[AC_MSG_ERROR(["sed for conf.d/squash_dir failed"])])
AS_IF([diff conf.d/squash_dir patching.tmp],
	[],
	[AC_MSG_NOTICE([patching conf.d/squash_dir])
	AS_IF([cat patching.tmp >|conf.d/squash_dir],
		[],
		[AC_MSG_ERROR(["cannot patch conf.d/squash_dir"])])])
AS_IF([rm patching.tmp],
	[],
	[AC_MSG_ERROR(["cannot remove temporary file ./patching.tmp"])])

AC_OUTPUT()
