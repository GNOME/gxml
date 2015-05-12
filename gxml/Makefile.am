-include $(top_srcdir)/git.mk

# Empty variable to be added elements later
CLEANFILES=
BUILT_SOURCES=
AM_VALAFLAGS=

### Library

# Library to create
lib_LTLIBRARIES = libgxml-0.6.la

# Vala source code
sources = \
	namespace-info.vala \
	Attribute.vala \
	Comment.vala\
	CDATA.vala \
	Document.vala \
	DocumentType.vala \
	Element.vala \
	Namespace.vala \
	Node.vala \
	Notation.vala \
	ProcessingInstruction.vala \
	Text.vala \
	libxml-Attr.vala \
	libxml-AttrChildNodeList.vala \
	libxml-BackedNode.vala \
	libxml-ChildNodeList.vala \
	libxml-CDATASection.vala \
	libxml-CharacterData.vala \
	libxml-Comment.vala \
	libxml-DocumentFragment.vala \
	libxml-DocumentType.vala \
	libxml-Document.vala \
	libxml-DomException.vala \
	libxml-Element.vala \
	libxml-Entity.vala \
	libxml-EntityChildNodeList.vala\
	libxml-EntityReference.vala \
	libxml-Error.vala \
	libxml-Implementation.vala \
	libxml-LinkedList.vala \
	libxml-NamedNodeMap.vala \
	libxml-NamedAttrMap.vala \
	libxml-NamespaceAttr.vala \
	libxml-NodeChildNodeList.vala \
	libxml-NodeList.vala \
	libxml-NodeType.vala \
	libxml-Node.vala \
	libxml-Notation.vala \
	libxml-ProcessingInstruction.vala \
	libxml-TagNameNodeList.vala \
	libxml-NamespaceAttrNodeList.vala \
	libxml-Text.vala \
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
	SerializableContainer.vala \
	TwAttribute.vala \
	TwComment.vala \
	TwDocument.vala \
	TwElement.vala \
	TwNamespace.vala \
	TwNode.vala \
	TwText.vala


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

if DEBUG
  AM_VALAFLAGS += \
    -D DEBUG \
    --enable-mem-profiler \
    -g
endif


# library flags
AM_VALAFLAGS += \
	$(ERROR_VALAFLAGS) \
	--library=gxml-0.6 \
	$(top_srcdir)/vapi/config.vapi \
	$(top_srcdir)/vapi/xlibxml-1.0.vapi \
	--vapidir=. \
	--vapidir=$(top_srcdir)/vapi \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--includedir gxml \
	--vapi gxml-0.6.vapi \
	-H gxml.h \
	-C \
	$(NULL)

libgxml_0_6_la_LIBADD = \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS) \
	$(VALA_LIBS) \
	$(NULL)

libgxml_0_6_la_LDFLAGS = \
	-version-info "$(LT_CURRENT)":"$(LT_REVISION)":"$(LT_AGE)"

gxml_0_6_la_vala.stamp: $(sources)
	$(VALAC) $(AM_VALAFLAGS) $^

$(sources:.vala=.c): gxml_0_6_la_vala.stamp

libgxml_0_6_la_SOURCES= \
  $(sources:.vala=.c) \
  xlibxml.c
libgxml_0_6_la_DEPENDENCIES= gxml_0_6_la_vala.stamp

# .h header file
gxml.h: gxml_0_6_la_vala.stamp
gxmldir= $(includedir)/gxml-$(API_VERSION)/gxml
gxml_HEADERS = gxml.h xlibxml.h

# .vapi Vala API file
gxml-0.6.vapi: gxml_0_6_la_vala.stamp
vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = \
	gxml-0.6.vapi \
	gxml-0.6.deps \
	$(NULL)

# .pc pkg-config file
pkgconfig_in = gxml-0.6.pc.in
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = $(pkgconfig_in:.in=)

EXTRA_DIST = \
	$(sources) \
	$(pkgconfig_in) \
	$(NULL)

GITIGNOREFILES = \
	$(sources:.vala=.c) \
	libgxml_0_6_la_vala.stamp \
	$(NULL)


BUILT_SOURCES += \
	gxml_0_6_la_vala.stamp \
	gxml.h \
	gxml-0.6.vapi \
	$(NULL)


# This makes GObject Introspection optional and requires to use --enable-instrospection switch on configure
if HAVE_INTROSPECTION

### GObject Introspection
# dlname:
#   Extract our dlname like libfolks does, see bgo#658002 and bgo#585116
#   This is what g-ir-scanner does.
libgxml_dlname = \
        `$(SED) -n "s/^dlname='\([A-Za-z0-9.+-]\+\)'/\1/p" libgxml-0.6.la`


AM_VALAFLAGS += \
	--gir=GXml-$(API_VERSION).gir

INTROSPECTION_GIRS = GXml-$(API_VERSION).gir
INTROSPECTION_COMPILER_ARGS = --includedir=. -l $(libgxml_dlname)

GXml-0.6.gir: libgxml-0.6.la

GXml-0.6.typelib: $(INTROSPECTION_GIRS)
	$(INTROSPECTION_COMPILER) $(INTROSPECTION_COMPILER_ARGS)  $< -o $@

girdir = $(INTROSPECTION_GIRDIR)
gir_DATA = $(INTROSPECTION_GIRS)
typelibdir = $(INTROSPECTION_TYPELIBDIR)
typelib_DATA = GXml-0.6.typelib
CLEANFILES += $(gir_DATA) $(typelib_DATA)

endif

if PLATFORM_WIN32
AM_VALAFLAGS += \
	--symbols=gxml.symbols

libgxml_0_6_la_LDFLAGS += -shared -o libgxml-0.6.dll -no-undefined \
	-out-imlib -export-all-symbols -output-def

gxml.symbols: gxml_0_6_la_vala.stamp

libgxml-0.6.def: gxml.symbols
	(echo -e EXPRTS; $(CPP) -P $(DEF_FLAGS) \
	- <$^ | sed -e '/^$$/d' -e 's/^/ /' -e 's/G_GNUC_[^ ]*//g' \
	| sort) > gxml.def.tmp && mv gxml.def.tmp libgxml-0.6.def

libgxml-0.6.def: libgxml-0.6.la
libgxmldefdir=$(libdir)
libgxmldef_DATA=libgxml-0.6.def

CLEANFILES += \
	gxml.symbols \
	libgxml-0.6.def

BUILT_SOURCES += \
	libgxml-0.6.def

endif

CLEANFILES += \
	$(pkgconfig_DATA) \
	namespace-info.vala \
	$(sources:.vala=.c) \
	gxml-0.6.vapi \
	gxml.h

