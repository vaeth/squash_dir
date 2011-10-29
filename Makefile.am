# Copyright (c)
#  Martin Väth <martin@mvath.de>

AUTOMAKE_OPTIONS = foreign 1.10 no-dist-gzip dist-bzip2

EXTRA_DIST = \
mk \
autogen.sh \
INSTALL

dist_doc_DATA = \
README \
AUTHORS \
ChangeLog

CLEANFILES = \
portage/env/sys-fs/squashfs-tools

dist_noinst_DATA = \
portage/env/sys-fs/squashfs-tools.in

nobase_dist_doc_DATA = \
squashfs-tools-patch/README \
squashfs-tools-patch/squashfs-tools-3.3-progress-stderr.patch \
squashfs-tools-patch/squashfs-tools-3.4-progress-stderr.patch \
squashfs-tools-patch/squashfs-tools-4.0-progress-stderr.patch

# Actually, this should be ..._SCRIPTS, but this is not allowed.
# So we cheat that it is data and change permissions in install-data-hook:
nobase_dist_sysconf_DATA = \
init.d/squash_dir

dist_sbin_SCRIPTS = \
squash-dir

if SQUASHFS_TOOLS_PATCH
nobase_nodist_sysconf_DATA = \
portage/env/sys-fs/squashfs-tools
endif

# Remove things created by autogen.sh
maintainer-clean-local:
	$(AM_V_at)$(RM) -fr "$(top_srcdir)/build" "$(top_srcdir)/config" "$(top_srcdir)/m4" "$(top_srcdir)"/tmpcvs* "$(top_srcdir)"/tmpwrk*
	$(AM_V_at)$(RM) -f "$(top_srcdir)/aclocal.m4" "$(top_srcdir)/Makefile.in" "$(top_srcdir)/configure"
	$(AM_V_at)for i in tar.xz tar.lzma tar.bz2 tar.gz zip tar.Z shar.gz shar; do rm -vf -- "$(top_srcdir)"/$(PACKAGE)-*."$${i}"; done

# Remove things created by autogen.sh also in the tarball
dist-hook:
	$(AM_V_at)$(RM) -fr "$(distdir)/build" "$(distdir)/config" "$(distdir)/m4"
	$(AM_V_at)$(RM) "$(distdir)/aclocal.m4" "$(distdir)/Makefile.in" "$(distdir)/configure"

install-data-hook:
	$(AM_V_at)for i in $(nobase_dist_sysconf_DATA); do chmod a+x -- "$(DESTDIR)$(sysconfdir)/$${i}"; done

SUFFIXES = .in
.in:
	$(AM_V_GEN)$(SED) \
		-e "s,\@PACKAGE_STRING\@,$(PACKAGE_STRING),g" \
		-e "s,\@PACKAGE\@,$(PACKAGE),g" \
		-e "s,\@SYSCONFDIR\@,$(sysconfdir),g" \
		-e "s,\@DOCDIR\@,$(docdir),g" \
		-e "s,\@DECOMPRESS\@,$(DECOMPRESS),g" \
	"$<" > "$@"
