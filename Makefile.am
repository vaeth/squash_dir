# (C) Martin V\"ath <martin@mvath.de>

AUTOMAKE_OPTIONS = foreign 1.10 no-dist-gzip dist-bzip2 -Wobsolete -Wportability -Wextra-portability

EXTRA_DIST = \
.gitignore \
contrib \
autogen.sh \
INSTALL \
systemd/squash_dir.service \
systemd/squash_dir@.service \
zsh/_openrc-wrapper \
zsh/_squash_dir

dist_doc_DATA = \
README \
AUTHORS \
ChangeLog

CLEANFILES = \
patching.tmp

# Actually, we want nobase_dist_sysconf_SCRIPTS,
# but stupid automake claims it knows better than me and forbids this.
pkgdatadir=$(sysconfdir)
nobase_dist_pkgdata_SCRIPTS = \
init.d/squash_dir

nobase_dist_sysconf_DATA = \
conf.d/squash_dir

dist_sbin_SCRIPTS = \
sbin/openrc-wrapper \
sbin/squash_dir

# Remove things created by autogen.sh
maintainer-clean-local:
	$(AM_V_at)$(RM) -fr "$(top_srcdir)/build" "$(top_srcdir)/config" "$(top_srcdir)/m4" "$(top_srcdir)"/tmpcvs* "$(top_srcdir)"/tmpwrk*
	$(AM_V_at)$(RM) -f "$(top_srcdir)/aclocal.m4" "$(top_srcdir)/Makefile.in" "$(top_srcdir)/configure"
	$(AM_V_at)for i in tar.xz tar.bz2 tar.gz zip; do rm -vf -- "$(top_srcdir)"/$(PACKAGE)-*."$${i}"; done

# Remove things created by autogen.sh also in the tarball
dist-hook:
	$(AM_V_at)$(RM) -fr "$(distdir)/build" "$(distdir)/config" "$(distdir)/m4"
	$(AM_V_at)$(RM) "$(distdir)/aclocal.m4" "$(distdir)/Makefile.in" "$(distdir)/configure"

install-data-local:
	$(AM_V_at)if test x"$(ZSH_COMPLETION)" != x"" ; \
	then	$(INSTALL_DATA) -D "$(srcdir)/zsh/_squash_dir" "$(DESTDIR)$(ZSH_COMPLETION)/_squash_dir" && \
		$(INSTALL_DATA) -D "$(srcdir)/zsh/_openrc-wrapper" "$(DESTDIR)$(ZSH_COMPLETION)/_openrc-wrapper" ; \
	fi
	$(AM_V_at)if test x"$(SYSTEMSYSTEMUNITDIR)" != x"" ; \
	then	$(INSTALL_DATA) -D "$(srcdir)/systemd/squash_dir.service" "$(DESTDIR)$(SYSTEMSYSTEMUNITDIR)/squash_dir.service" && \
		$(INSTALL_DATA) -D "$(srcdir)/systemd/squash_dir@.service" "$(DESTDIR)$(SYSTEMSYSTEMUNITDIR)/squash_dir@.service" ; \
	fi

uninstall-local:
	$(AM_V_at)if test x"$(ZSH_COMPLETION)" != x"" ; \
	then	$(RM) "$(DESTDIR)$(ZSH_COMPLETION)/_squash_dir" && \
		$(RM) "$(DESTDIR)$(ZSH_COMPLETION)/_openrc-wrapper" ; \
	fi
	$(AM_V_at)if test x"$(SYSTEMSYSTEMUNITDIR)" != x"" ; \
	then	$(RM) "$(DESTDIR)$(SYSTEMSYSTEMUNITDIR)/squash_dir.service" && \
		$(RM) "$(DESTDIR)$(SYSTEMSYSTEMUNITDIR)/squash_dir@.service" ; \
	fi
