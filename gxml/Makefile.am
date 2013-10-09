## Process this file with automake to produce Makefile.in
## Created by Anjuta and modified based on libfolks


### General Compilation flags
AM_CPPFLAGS = \
	-include $(CONFIG_HEADER) \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DG_LOG_DOMAIN=\"gxml\" \
	$(NULL)

AM_CFLAGS = \
	 -g \
	$(GLIB_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GEE_CFLAGS) \
	$(VALA_CFLAGS) \
	$(NULL)

# -Wall   # TODO: add this back when we can properly handle more libxml2/vala warnings


# TODO: remove this, or remove -Wall and -g from libgxml_la_CFLAGS
# AM_CFLAGS = \
#	 -Wall \
#	 -g \
#


### Library

# Library to create
lib_LTLIBRARIES = libgxml.la

VALAC=valac

# Vala source code
libgxml_la_SOURCES = \
	Attr.vala \
	BackedNode.vala \
	CDATASection.vala \
	CharacterData.vala \
	Comment.vala \
	Document.vala \
	DocumentFragment.vala \
	DocumentType.vala \
	Node.vala \
	DomException.vala \
	Element.vala \
	Entity.vala \
	EntityReference.vala \
	Implementation.vala \
	NamespaceAttr.vala \
	NodeList.vala \
	NodeType.vala \
	Notation.vala \
	ProcessingInstruction.vala \
	Text.vala \
	Serializable.vala \
	SerializableObjectModel.vala \
	SerializableJson.vala \
	Serialization.vala \
	$(NULL)

gxml.vala.stamp: $(libgxml_la_SOURCES)


# libgxml_la_SOURCES = \
# 	gxml.vala.stamp \
# 	$(libgxml_la_VALASOURCES:.vala=.c) \
# 	$(NULL)

# library flags
libgxml_la_VALAFLAGS = \
	$(AM_VALAFLAGS) \
	$(ERROR_VALAFLAGS) \
	--gir=GXml-$(API_VERSION).gir \
	--library=gxml \
	$(top_srcdir)/vapi/config.vapi \
	--vapidir=. \
	--vapidir=$(top_srcdir)/vapi \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--includedir gxml \
	--vapi gxml.vapi \
	-H gxml.h \
	$(NULL)

libgxml_la_LIBADD = \
	$(AM_LDADD) \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS) \
	$(VALA_LIBS) \
	$(NULL)

libgxml_la_LDFLAGS = \
	$(AM_LDFLAGS) \
	-version-info "$(LT_CURRENT)":"$(LT_REVISION)":"$(LT_AGE)"

# .h header file
gxmldir= $(includedir)/gxml
gxml_HEADERS = gxml.h

# .vapi Vala API file
vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = \
	gxml.vapi \
	gxml.deps \
	$(NULL)

# .pc pkg-config file
pkgconfig_in = gxml.pc.in
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = $(pkgconfig_in:.in=)

EXTRA_DIST = \
	$(pkgconfig_in) \
	$(NULL)

GITIGNOREFILES = \
	$(libgxml_la_SOURCES:.vala=.c) \
	libgxml_la_vala.stamp \
	$(NULL)



### GObject Introspection

if ENABLE_GI_SYSTEM_INSTALL
girdir = $(INTROSPECTION_GIRDIR)
typelibdir = $(INTROSPECTION_TYPELIBDIR)
else
girdir = $(datadir)/gir-1.0
typelibdir = $(libdir)/girepository-1.0
endif

# dlname:
#   Extract our dlname like libfolks does, see bgo#658002 and bgo#585116
#   This is what g-ir-scanner does.
libgxml_dlname = \
        `$(SED) -n "s/^dlname='\([A-Za-z0-9.+-]\+\)'/\1/p" libgxml.la`

-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS =
INTROSPECTION_COMPILER_ARGS = --includedir=. -l $(libgxml_dlname)

GXml-$(API_VERSION).gir: libgxml.la
GIRS = GXml-$(API_VERSION).gir

dist_gir_DATA = $(GIRS)
nodist_typelib_DATA = $(GIRS:.gir=.typelib)



### Files to clean
BUILT_SOURCES = \
	gxml.vala.stamp \
	gxml.h \
	gxml.vapi \
	$(NULL)

# 	gxml.pc
# 	$(libgxml_la_VALASOURCES:.vala=.c) \
# 	$(vapi_DATA) \
# 	$(typelibs_DATA) \
# 	$(INTROSPECTION_GIRS) \
# 	gxml.vala.stamp

## File used to indicate whether code needs rebuilding (?)
CLEANFILES = $(INTROSPECTION_GIRS) $(typelibs_DATA) $(BUILT_SOURCES) $(nodist_typelib_DATA)
MAINTAINERCLEANFILES = $(BUILT_SOURCES) $(dist_gir_DATA)



-include $(top_srcdir)/git.mk
