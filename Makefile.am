## Process this file with automake to produce Makefile.in
## Created by Anjuta

# What does this do? :D
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = gxml test po

if HAVE_VALADOC
SUBDIRS += docs
endif

DISTCHECK_CONFIGURE_FLAGS = \
	--enable-docs \
	$(NULL)


gxmldocdir = ${prefix}/doc/gxml
gxmldoc_DATA = \
	README\
	COPYING\
	AUTHORS\
	ChangeLog\
	INSTALL\
	NEWS


INTLTOOL_FILES = intltool-extract.in \
	intltool-merge.in \
	intltool-update.in

EXTRA_DIST = $(gxmldoc_DATA) \
	$(INTLTOOL_FILES)

DISTCLEANFILES = intltool-extract \
	intltool-merge \
	intltool-update \
	po/.intltool-merge-cache


# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(gxmldocdir)
