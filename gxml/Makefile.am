
# Library to create
lib_LTLIBRARIES = libgxml-0.14.la


# Empty variable to be added elements later
CLEANFILES=
BUILT_SOURCES=

### Library


# Vala source code
sources = \
	gxml-init.vala \
	namespace-info.vala \
	Attribute.vala \
	Comment.vala\
	CDATA.vala \
	Character.vala \
	Document.vala \
	DocumentType.vala \
	Element.vala \
	Namespace.vala \
	Node.vala \
	Notation.vala \
	ProcessingInstruction.vala \
	Text.vala \
	NodeType.vala \
	Serializable.vala \
	SerializableProperty.vala \
	SerializableBool.vala \
	SerializableDouble.vala \
	SerializableFloat.vala \
	SerializableEnum.vala \
	SerializableInt.vala \
	SerializableValueList.vala \
	Enumeration.vala \
	SerializableObjectModel.vala \
	SerializableGeeTreeMap.vala \
	SerializableGeeHashMap.vala \
	SerializableMapKey.vala \
	SerializableGeeDualKeyMap.vala \
	SerializableMapDualKey.vala \
	SerializableGeeArrayList.vala \
	SerializableContainer.vala \
	TAttribute.vala \
	TComment.vala \
	TCDATA.vala \
	TDocument.vala \
	TElement.vala \
	TNamespace.vala \
	TNode.vala \
	TProcessingInstruction.vala \
	TText.vala \
	GHtml.vala \
	GXmlAttribute.vala \
	GXmlComment.vala \
	GXmlCharacter.vala \
	GXmlChildNode.vala \
	GXmlCDATA.vala \
	GXmlDocument.vala \
	GXmlDomCollections.vala \
	GXmlDomEvents.vala \
	GXmlDomRange.vala \
	GXmlElement.vala \
	GXmlNamespace.vala \
	GXmlNode.vala \
	GXmlProcessingInstruction.vala \
	GXmlText.vala \
	GXmlHashMapAttr.vala \
	GXmlListChildren.vala \
	GXmlListNamespaces.vala \
	DomAttr.vala \
	DomCharacter.vala \
	DomCollections.vala \
	DomDocument.vala \
	DomElement.vala \
	DomEvents.vala \
	DomMutationObservers.vala \
	DomNode.vala \
	DomRange.vala \
	XPath.vala \
	GXPathObject.vala \
	GomDocument.vala \
	GomElement.vala \
	GomAttr.vala \
	GomNode.vala \
	GomText.vala \
	GomObject.vala \
	GomCollections.vala \
	GomProperty.vala \
	Parser.vala \
	XParser.vala \
	Schema.vala \
	GomSchema.vala \
	$(NULL)


AM_VALAFLAGS= \
	--vapidir=$(VAPIDIR) \
	$(ERROR_AM_VALAFLAGS) \
	--library=gxml-0.14 \
	$(top_srcdir)/vapi/config.vapi \
	$(top_srcdir)/vapi/xlibxml-1.0.vapi \
	--vapidir=. \
	--vapidir=$(top_srcdir)/vapi \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--pkg gobject-2.0 \
	--pkg gio-2.0 \
	--includedir gxml \
	-H gxml.h -C \
	$(NULL)

# library flags
#libgxml_0_14_la_AM_VALAFLAGS=




### General Compilation flags
AM_CPPFLAGS = \
	-include $(CONFIG_HEADER) \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DG_LOG_DOMAIN=\"gxml\" \
	-I$(top_srcdir) \
	$(NULL)

AM_CFLAGS = \
	-g \
	$(GLIB_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GEE_CFLAGS) \
	$(VALA_CFLAGS) \
	-I$(top_srcdir) \
	$(NULL)


if BUILD_DEVHELP_DOCS

AM_VALAFLAGS += \
	--vapi-comments

endif

# -Wall   # TODO: add this back when we can properly handle more libxml2/vala warnings

if DEBUG
AM_VALAFLAGS += \
	-D DEBUG \
	--enable-mem-profiler \
	-g
endif

libgxml_0_14_la_LIBADD = \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS) \
	$(VALA_LIBS) \
	$(NULL)

libgxml_0_14_la_LDFLAGS = \
	-version-info "$(LT_CURRENT)":"$(LT_REVISION)":"$(LT_AGE)"

vala-stamp: $(sources)
	@rm -f vala-temp
	@touch vala-temp
	$(VALAC) $(AM_VALAFLAGS) $^
	@mv -f vala-temp $@

$(sources:.vala=.c): vala-stamp
## Recover from the removal of $@
	@if test -f $@; then :; else \
		trap ’rm -rf vala-lock vala-stamp’ 1 2 13 15; \
		if mkdir vala-lock 2>/dev/null; then \
## This code is being executed by the first process.
			rm -f vala-stamp; \
			$(MAKE) $(AM_MAKEFLAGS) vala-stamp; \
			rmdir vala-lock; \
		else \
## This code is being executed by the follower processes.
## Wait until the first process is done.
			while test -d vala-lock; do sleep 1; done; \
## Succeed if and only if the first process succeeded.
			test -f vala-stamp; exit $$?; \
		fi; \
		fi

libgxml_0_14_la_SOURCES= \
	$(sources:.vala=.c) \
	xlibxml.c \
	$(NULL)

# .h header file
gxml.h: libgxml-0.14.la
gxmldir= $(includedir)/gxml-$(API_VERSION)/gxml
gxml_HEADERS = gxml.h xlibxml.h

# .vapi Vala API file
gxml-0.14.vapi: libgxml-0.14.la
vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = \
	gxml-0.14.vapi \
	gxml-0.14.deps \
	$(NULL)

# .pc pkg-config file
pkgconfig_in = gxml-0.14.pc.in
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = $(pkgconfig_in:.in=)

EXTRA_DIST = \
	$(sources) \
	$(pkgconfig_in) \
	$(NULL)

#GITIGNOREFILES = \
#	$(sources:.vala=.c) \
#	$(NULL)

# This makes GObject Introspection optional and requires to use --enable-instrospection switch on configure
if HAVE_INTROSPECTION

### GObject Introspection
# dlname:
#   Extract our dlname like libfolks does, see bgo#658002 and bgo#585116
#   This is what g-ir-scanner does.
libgxml_dlname=\
	`$(SED) -nE "s/^dlname='([A-Za-z0-9.+-]+)'/\1/p" libgxml-0.14.la`
#libgxml_dlname=\
#	`$(GREP) -e dlname libgxml-0.14.la | $(SED) s/dlname=\'// | $(SED) s/\'//`

AM_VALAFLAGS += \
	--gir=GXml-$(API_VERSION).gir

INTROSPECTION_GIRS = GXml-$(API_VERSION).gir
INTROSPECTION_COMPILER_ARGS = --includedir=. -l $(libgxml_dlname)

GXml-0.14.gir: libgxml-0.14.la

GXml-0.14.typelib: $(INTROSPECTION_GIRS)
	$(INTROSPECTION_COMPILER) $(INTROSPECTION_COMPILER_ARGS)  $< -o $@

girdir = $(INTROSPECTION_GIRDIR)
gir_DATA = $(INTROSPECTION_GIRS)
typelibdir = $(INTROSPECTION_TYPELIBDIR)
typelib_DATA = GXml-0.14.typelib
CLEANFILES += $(gir_DATA) $(typelib_DATA)

endif

if PLATFORM_WIN32
AM_VALAFLAGS += \
	--symbols=gxml.symbols

libgxml_0_14_la_LDFLAGS += -shared -o libgxml-0.14.dll -no-undefined \
	-out-imlib -export-all-symbols -output-def

gxml.symbols: libgxml-0.14.la

libgxml-0.14.def: gxml.symbols
	(echo -e EXPRTS; $(CPP) -P $(DEF_FLAGS) \
	- <$^ | sed -e '/^$$/d' -e 's/^/ /' -e 's/G_GNUC_[^ ]*//g' \
	| sort) > gxml.def.tmp && mv gxml.def.tmp libgxml-0.14.def

libgxml-0.14.def: libgxml-0.14.la
libgxmldefdir=$(libdir)
libgxmldef_DATA=libgxml-0.14.def

CLEANFILES += \
	gxml.symbols \
	libgxml-0.14.def

BUILT_SOURCES += \
	libgxml-0.14.def

endif

CLEANFILES += \
	$(sources:.vala=.c) \
	vala-stamp \
	$(pkgconfig_DATA) \
	namespace-info.vala \
	gxml-0.14.vapi \
	gxml.h

-include $(top_srcdir)/git.mk

