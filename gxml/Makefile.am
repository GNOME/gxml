## Process this file with automake to produce Makefile.in

## Created by Anjuta

NULL =


AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" 

BUILT_SOURCES = gxml.vala.stamp
CLEANFILES = gxml.vala.stamp

AM_CFLAGS =\
	 -Wall\
	 -g \
	$(GLIB_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GEE_CFLAGS) \
	$(VALA_CFLAGS) \
	$(NULL)

lib_LTLIBRARIES = libgxml.la

VALAFLAGS = \
    $(top_srcdir)/vapi/config.vapi \
    --vapidir=$(top_srcdir)/vapi \
    --pkg libxml-2.0 \
    --pkg gee-1.0 \
    --pkg gobject-2.0 \
    --pkg gio-2.0 \
    $(NULL)

libgxml_la_VALASOURCES = \
	Attr.vala \
	BackedNode.vala \
	CDATASection.vala \
	CharacterData.vala \
	Comment.vala \
	Document.vala \
	DocumentFragment.vala \
	DocumentType.vala \
	DomError.vala \
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
	XNode.vala \
	$(NULL)

libgxml_la_SOURCES = \
	gxml.vala.stamp \
	$(libgxml_la_VALASOURCES:.vala=.c) \
	$(NULL)	

gxml-1.0.vapi gxml.vala.stamp GXml-1.0.gir gxml-dom.h: $(libgxml_la_VALASOURCES)
	$(VALA_COMPILER) $(VALAFLAGS) -C -H $(top_builddir)/gxml/gxml-dom.h --gir=GXmlDom-1.0.gir  --library gxmldom-1.0 $^
	@touch $@



libgxml_la_LDFLAGS = 

libgxml_la_LIBADD = \
	$(GLIB_LIBS) \
	$(LIBXML_LIBS) \
	$(GIO_LIBS) \
	$(GEE_LIBS) \
	$(VALA_LIBS) \
	$(NULL)

include_HEADERS = \
	$(top_builddir)/gxml/gxml-dom.h \
	$(NULL)


pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libgxml-1.0.pc

gxmlincludedir=$(includedir)/libgxml-1.0
gxmlinclude_HEADERS= gxml-dom.h

# GObject Introspection

if ENABLE_GI_SYSTEM_INSTALL
girdir = $(INTROSPECTION_GIRDIR)
typelibsdir = $(INTROSPECTION_TYPELIBDIR)
else
girdir = $(datadir)/gir-1.0
typelibsdir = $(libdir)/girepository-1.0
endif

# GIR files are generated automatically by Valac so is not necessary to scan source code to generate it
INTROSPECTION_GIRS =
INTROSPECTION_GIRS += GXmlDom-1.0.gir
INTROSPECTION_COMPILER_ARGS = \
    --includedir=.  

GXmlDom-1.0.typelib: $(INTROSPECTION_GIRS)
	$(INTROSPECTION_COMPILER) $(INTROSPECTION_COMPILER_ARGS)  $< -o $@

gir_DATA = $(INTROSPECTION_GIRS)
typelibs_DATA = GXmlDom-1.0.typelib

vapidir = $(VALA_VAPIDIR)
vapi_DATA=gxmldom-1.0.vapi

CLEANFILES += $(INTROSPECTION_GIRS) $(typelibs_DATA) gxml-1.0.vapi gxml-dom.h

EXTRA_DIST = \
	libgxml-1.0.pc.in \
	$(libgxml_la_VALASOURCES) \
	$(typelibs_DATA) \
	$(INTROSPECTION_GIRS) \
	gxml.vala.stamp
