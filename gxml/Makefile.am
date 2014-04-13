-include $(top_srcdir)/git.mk

# Empty variable to be added elements later
CLEANFILES=


### Library

# Library to create
lib_LTLIBRARIES = libgxml-0.4.la

# Vala source code
sources = \
	namespace-info.vala \
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
	Error.vala \
	Implementation.vala \
	NamedNodeMap.vala \
	NamespaceAttr.vala \
	NodeList.vala \
	NodeType.vala \
	Notation.vala \
	ProcessingInstruction.vala \
	Text.vala \
	Serializable.vala \
	Enumeration.vala \
	SerializableObjectModel.vala \
	SerializableJson.vala \
	Serialization.vala \
	SerializableGeeTreeMap.vala \
	SerializableGeeHashMap.vala \
	SerializableMapKey.vala \
	SerializableGeeDualKeyMap.vala \
	SerializableMapDualKey.vala \
	SerializableGeeArrayList.vala \
	SerializableContainer.vala


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


# library flags
AM_VALAFLAGS = \
	$(ERROR_VALAFLAGS) \
	--library=gxml-0.4 \
	$(top_srcdir)/vapi/config.vapi \
	--vapidir=. \
	--vapidir=$(top_srcdir)/vapi \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--includedir gxml \
	--vapi gxml-0.4.vapi \
	-H gxml.h \
	-C \
	$(NULL)

libgxml_0_4_la_LIBADD = \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS) \
	$(VALA_LIBS) \
	$(NULL)

libgxml_0_4_la_LDFLAGS = \
	-version-info "$(LT_CURRENT)":"$(LT_REVISION)":"$(LT_AGE)"

gxml_0_4_la_vala.stamp: $(sources)
	$(VALAC) $(AM_VALAFLAGS) $^

libgxml_0_4_la_SOURCES=$(sources:.vala=.c)

# .h header file
gxml.h: gxml_0_4_la_vala.stamp
gxmldir= $(includedir)/gxml-$(API_VERSION)/gxml
gxml_HEADERS = gxml.h

# .vapi Vala API file
gxml-0.4.vapi: gxml_0_4_la_vala.stamp
vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = \
	gxml-0.4.vapi \
	gxml-0.4.deps \
	$(NULL)

# .pc pkg-config file
pkgconfig_in = gxml-0.4.pc.in
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = $(pkgconfig_in:.in=)

EXTRA_DIST = \
	$(sources) \
	$(pkgconfig_in) \
	$(NULL)

GITIGNOREFILES = \
	$(libgxml_0_4_la_SOURCES:.vala=.c) \
	libgxml_0_4_la_vala.stamp \
	$(NULL)



### GObject Introspection
# dlname:
#   Extract our dlname like libfolks does, see bgo#658002 and bgo#585116
#   This is what g-ir-scanner does.
libgxml_dlname = \
        `$(SED) -n "s/^dlname='\([A-Za-z0-9.+-]\+\)'/\1/p" libgxml-0.4.la`

# This makes GObject Introspection optional and requires to use --enable-instrospection switch on configure
if HAVE_INTROSPECTION

AM_VALAFLAGS += \
	--gir=GXml-$(API_VERSION).gir

INTROSPECTION_GIRS = GXml-$(API_VERSION).gir
INTROSPECTION_COMPILER_ARGS = --includedir=. -l $(libgxml_dlname)

GXml-0.4.gir: libgxml-0.4.la

GXml-0.4.typelib: $(INTROSPECTION_GIRS)
	$(INTROSPECTION_COMPILER) $(INTROSPECTION_COMPILER_ARGS)  $< -o $@

girdir = $(INTROSPECTION_GIRDIR)
gir_DATA = $(INTROSPECTION_GIRS)
typelibdir = $(INTROSPECTION_TYPELIBDIR)
typelib_DATA = GXml-0.4.typelib
CLEANFILES += $(gir_DATA) $(typelibs_DATA)
endif

if PLATFORM_WIN32
libgxml_0_4_la_LDFLAGS += -export-symbols $(builddir)/libgxml-0.4.def
libgxml_0_4_la_DEPENDENCIES = libgxml-0.4.def

libgxml-0.4.def: gxml.symbols
	(echo -e EXPORTS; $(CPP) -P $(DEF_FLAGS) - <$(srcdir)/gxml.symbols | sed -e '/^$$/d' -e 's/^/ /' -e 's/G_GNUC_[^ ]*//g' | sort) > gxml.def.tmp && mv gxml.def.tmp libgxml-0.4.def

libgxml-0.4.lib: libgxml-0.4.def
	$(DLLTOOL) --dllname libgxml-0.4.a --def libgxml-0.4.def --output-lib libgxml-0.4.lib

libgxml-0.4.lib: libgxml-0.4.la
libgxmllibdir=$(libdir)
libgxmllib_DATA=libgxml-0.4.lib

libgxml-0.4.def: libgxml-0.4.la
libgxmldefdir=$(libdir)
libgxmldef_DATA=libgxml-0.4.def

endif



### Files to clean
BUILT_SOURCES = \
	gxml_0_4_la_vala.stamp \
	gxml.h \
	gxml-0.4.vapi \
	$(NULL)

CLEANFILES += \
	$(pkgconfig_DATA) \
	namespace-info.vala \
	$(sources:.vala=.c) \
	gxml-0.4.vapi \
	gxml.h \
	$(gir_DATA) \
	$(typelib_DATA)

