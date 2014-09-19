## Process this file with automake to produce Makefile.in
## Created by Anjuta

ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}


# Set up subdirectories to traverse
SUBDIRS = gxml test po examples

if ENABLE_DOCS
SUBDIRS += docs
endif

# Define available flags
DISTCHECK_CONFIGURE_FLAGS = \
	--disable-introspection \
	$(NULL)



### Specify files to include in dist

# in share/doc/
gxmldocdir = ${prefix}/doc/gxml
gxmldoc_DATA = \
	README \
	COPYING \
	AUTHORS \
	ChangeLog \
	INSTALL \
	NEWS

# with make dist
INTLTOOL_FILES = intltool-extract.in \
	intltool-merge.in \
	intltool-update.in

EXTRA_DIST = $(gxmldoc_DATA) \
	autogen.sh \
	vapi \
	config.rpath \
	$(INTLTOOL_FILES)




# Lists of generated files you want to be able to clean

MAINTAINERCLEANFILES = \
	ABOUT-NLS \
	$(srcdir)/aclocal.m4 \
	$(srcdir)/compile \
	$(srcdir)/config.guess \
	$(srcdir)/config.h.in \
	$(srcdir)/config.rpath \
	$(srcdir)/config.sub \
	$(srcdir)/depcomp \
	$(srcdir)/install-sh \
	$(srcdir)/ltmain.sh \
	$(srcdir)/missing \
	$(srcdir)/mkinstalldirs \
	$(srcdir)/ChangeLog \
	`find "$(srcdir)" -type f -name Makefile.in -print` \
	`find "m4" -type f -name "*.m4" ! -name "as-compiler-flag.m4" ! -name "introspection.m4" ! -name "vala.m4" -print` \
	po/Makevars.template \
	po/Rules-quot \
	po/boldquot.sed \
	po/en@boldquot.header \
	po/en@quot.header \
	po/insert-header.sin \
	po/missing \
	po/quot.sed \
	po/remove-potcdate.sin \
	$(NULL)

DISTCLEANFILES = intltool-extract \
	intltool-merge \
	intltool-update \
	po/.intltool-merge-cache \
	ChangeLog



# Automatically generate ChangeLog from git
# (do we need to call make ChangeLog ourselves?)

ChangeLog:
	@echo Creating $@
	@if test -d "$(srcdir)/.git"; then \
	  (GIT_DIR=$(top_srcdir)/.git ./missing --run git log --stat) | fmt --split-only > $@.tmp \
	  && mv -f $@.tmp $@ \
	  || ($(RM) $@.tmp; \
	      echo Failed to generate ChangeLog, your ChangeLog may be outdated >&2; \
	      (test -f $@ || echo git-log is required to generate this file >> $@)); \
	else \
	  test -f $@ || \
	  (echo A git checkout and git-log is required to generate ChangeLog >&2 && \
	  echo A git checkout and git-log is required to generate this file >> $@); \
	fi

.PHONY: ChangeLog



# Remove doc directory on uninstall (not sure why :D)
uninstall-local:
	-rm -r $(gxmldocdir)
