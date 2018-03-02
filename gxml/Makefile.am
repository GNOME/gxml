
# Library to create
lib_LTLIBRARIES = libgxml-0.16.la


# Empty variable to be added elements later
CLEANFILES=
BUILT_SOURCES=

### Library


# Vala source code
sources = \
	CssSelectorParser.vala \
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
	DomHtml.vala \
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

VALA_FLAGS= \
	--vapidir=$(VAPIDIR) \
	$(top_srcdir)/vapi/config.vapi \
	--vapidir=. \
	--vapidir=$(top_srcdir)/vapi \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--pkg gobject-2.0 \
	--pkg gio-2.0

AM_VALAFLAGS= \
	$(VALA_FLAGS) \
	--vapidir=$(VAPIDIR) \
	$(ERROR_AM_VALAFLAGS) \
	--library=gxml-@API_VERSION@ \
	--includedir gxml \
	-H gxml.h -C \
	$(NULL)

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

libgxml_0_16_la_LIBADD = \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS) \
	$(VALA_LIBS) \
	$(NULL)

libgxml_0_16_la_LDFLAGS = \
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

libgxml_0_16_la_SOURCES= \
	$(sources:.vala=.c) \
	xlibxml.c \
	$(NULL)


# .h header file
gxml.h: libgxml-$(API_VERSION).la
gxmldir= $(includedir)/gxml-$(API_VERSION)/gxml
gxml_HEADERS = gxml.h xlibxml.h

# .vapi Vala API file
gxml-@API_VERSION@.vapi: libgxml-$(API_VERSION).la

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = \
	gxml-$(API_VERSION).vapi \
	gxml-$(API_VERSION).deps \
	$(NULL)

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = gxml-$(API_VERSION).pc

EXTRA_DIST = \
	$(sources) \
	$(pkgconfig_in) \
	$(NULL)

DISTCLEANFILES= \
	gxml-$(API_VERSION).deps

# This makes GObject Introspection optional and requires to use --enable-instrospection switch on configure
if HAVE_INTROSPECTION

### GObject Introspection
# dlname:
#   Extract our dlname like libfolks does, see bgo#658002 and bgo#585116
#   This is what g-ir-scanner does.
libgxml_dlname=\
	`$(SED) -nE "s/^dlname='([A-Za-z0-9.+-]+)'/\1/p" libgxml-@API_VERSION@.la`
#libgxml_dlname=\
#	`$(GREP) -e dlname libgxml-@API_VERSION@.la | $(SED) s/dlname=\'// | $(SED) s/\'//`

AM_VALAFLAGS += \
	--gir=GXml-$(API_VERSION).gir

INTROSPECTION_GIRS = GXml-$(API_VERSION).gir
INTROSPECTION_COMPILER_ARGS = --includedir=. -l $(libgxml_dlname)

GXml-@API_VERSION@.gir: libgxml-$(API_VERSION).la

GXml-@API_VERSION@.typelib: $(INTROSPECTION_GIRS)
	$(INTROSPECTION_COMPILER) $(INTROSPECTION_COMPILER_ARGS)  $< -o $@

girdir = $(INTROSPECTION_GIRDIR)
gir_DATA = $(INTROSPECTION_GIRS)
typelibdir = $(INTROSPECTION_TYPELIBDIR)
typelib_DATA = GXml-$(API_VERSION).typelib
CLEANFILES += $(gir_DATA) $(typelib_DATA)

endif

if PLATFORM_WIN32
AM_VALAFLAGS += \
	--symbols=gxml.symbols

libgxml_0_16_la_LDFLAGS += -shared -o libgxml-$(API_VERSION).dll -no-undefined \
	-out-imlib -export-all-symbols -output-def

gxml.symbols: libgxml-$(API_VERSION).la

libgxml-@API_VERSION@.def: gxml.symbols
	(echo -e EXPRTS; $(CPP) -P $(DEF_FLAGS) \
	- <$^ | sed -e '/^$$/d' -e 's/^/ /' -e 's/G_GNUC_[^ ]*//g' \
	| sort) > gxml.def.tmp && mv gxml.def.tmp libgxml-$(API_VERSION).def

libgxml-@API_VERSION@.def: libgxml-$(API_VERSION).la
libgxmldefdir=$(libdir)
libgxmldef_DATA=libgxml-$(API_VERSION).def

CLEANFILES += \
	gxml.symbols \
	libgxml-$(API_VERSION).def

BUILT_SOURCES += \
	libgxml-$(API_VERSION).def

endif

CLEANFILES += \
	$(sources:.vala=.c) \
	vala-stamp \
	$(pkgconfig_DATA) \
	namespace-info.vala \
	gxml-$(API_VERSION).vapi \
	gxml.h

-include $(top_srcdir)/git.mk

if BUILD_DEVHELP_DOCS

VALADOC_FLAGS = \
	--driver $(VALA_API_VERSION) \
	--force \
	--package-name=GXml-$(API_VERSION) \
	--package-version=$(PACKAGE_VERSION)

gxmldocdir=$(datadir)/devhelp/books/GXml-$(API_VERSION)
gxmldoc_DATA = \
	devhelp/GXml-$(API_VERSION)/GXml-$(API_VERSION).devhelp2 \
	devhelp/GXml-$(API_VERSION)/*.png \
	devhelp/GXml-$(API_VERSION)/*.css \
	devhelp/GXml-$(API_VERSION)/*.js \
	devhelp/GXml-$(API_VERSION)/*.htm \
	devhelp/GXml-$(API_VERSION)/*.html

gxmldocimgdir=$(datadir)/devhelp/books/GXml-$(API_VERSION)/img
gxmldocimg_DATA=\
		devhelp/GXml-$(API_VERSION)/img/*

$(gxmldoc_DATA) $(gxmldocimg_DATA): gxml-doc

gxml-doc : $(sources)
	$(VALADOC) -o devhelp --doclet=devhelp $(VALADOC_FLAGS) $(VALA_FLAGS) $^

clean-local: clean-local-gxml-doc
.PHONY: clean-local-gxml-doc
clean-local-gxml-doc:
	-rm -rf devhelp
endif

