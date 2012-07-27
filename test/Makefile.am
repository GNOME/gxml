include $(top_srcdir)/gtester.mk

# gio-2.0 gxml gee-0.8 posix
# GTK GLIB GEE XML
# gxml_test
# gxml
# vapi_dirs = ../gxml ../vapi

# INCLUDES = \
# 	-I$(top_srcdir)/     \
# 	-I$(top_srcdir)/gxml
# 	$(LIBXML_CFLAGS)
#
# LIBS = \
# 	$(top_builddir)/gxml/libgxml-0.2.la

NULL =


AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\"

BUILT_SOURCES = gxml_test.vala.stamp
CLEANFILES = gxml_test.vala.stamp

AM_CFLAGS = \
	-Wall \
	-g \
	$(GLIB_CFLAGS) \
	$(GXML_CFLAGS) \
	$(GEE_CFLAGS) \
	$(LIBXML_CFLAGS) \
	-I../gxml \
	$(NULL)
# TODO: -I../gxml is a problem, find out how $(*_CFLAGS) work


noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS += gxml_test

VALAFLAGS = \
	$(top_srcdir)/vapi/config.vapi \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/gxml \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg posix \
	--pkg gxml-0.2 \
	--pkg libxml-2.0 \
	$(NULL)

gxml_test_VALASOURCES = \
	AttrTest.vala \
	CharacterDataTest.vala \
	DocumentTest.vala \
	ElementTest.vala \
	GXmlTest.vala \
	NodeListTest.vala \
	TextTest.vala \
	ValaLibxml2Test.vala \
	XmlSerializableTest.vala \
	DomNodeTest.vala \
	$(NULL)

gxml_test_SOURCES = \
	gxml_test.vala.stamp \
	$(gxml_test_VALASOURCES:.vala=.c) \
	$(NULL)

gxml_test.vala.stamp: $(gxml_test_VALASOURCES)
	$(VALA_COMPILER) $(VALAFLAGS) -C $^
	@touch $@

gxml_test_LDFLAGS =

gxml_test_LDADD = \
	$(GLIB_LIBS) \
	$(GXML_LIBS) \
	-L$(top_srcdir)/gxml -lgxml-0.2 \
	$(NULL)

#gxml_test_LIBADD = \
#	$(NULL)

include_HEADERS = \
	$(top_builddir)/gxml/gxml.h \
	$(NULL)

#...

CLEANFILES += gxml_test

EXTRA_DIST += \
	$(NULL)



#
#
#
#
# NULL =
#
#
# AM_CPPFLAGS = \
# 	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
# 	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
# 	-DPACKAGE_DATA_DIR=\""$(datadir)"\"
#
# BUILT_SOURCES = gxml.vala.stamp
# CLEANFILES = gxml.vala.stamp
#
# AM_CFLAGS =\
# 	 -Wall\
# 	 -g \
# 	$(GLIB_CFLAGS) \
# 	$(LIBXML_CFLAGS) \
# 	$(GIO_CFLAGS) \
# 	$(GEE_CFLAGS) \
# 	$(VALA_CFLAGS) \
# 	$(NULL)
#
# lib_LTLIBRARIES = libgxmldom-0.2.la
#
# VALAFLAGS = \
#     $(top_srcdir)/vapi/config.vapi \
#     --vapidir=$(top_srcdir)/vapi \
#     --pkg libxml-2.0 \
#     --pkg gee-0.8 \
#     --pkg gobject-2.0 \
#     --pkg gio-2.0 \
#     $(NULL)
#
#
# libgxmldom_0_2_la_SOURCES = \
# 	gxml.vala.stamp \
# 	$(libgxmldom_la_VALASOURCES:.vala=.c) \
# 	$(NULL)
#
# gxmldom-0.2.vapi gxml.vala.stamp GXmlDom-0.2.gir gxml-dom.h: $(libgxmldom_la_VALASOURCES)
# 	$(VALA_COMPILER) $(VALAFLAGS) -C -H $(top_builddir)/gxml/gxml-dom.h --gir=GXmlDom-0.2.gir  --library gxmldom-0.2 $^
# 	@touch $@
#
#
#
# libgxmldom_0_2_la_LDFLAGS =
#
# libgxmldom_0_2_la_LIBADD = \
# 	$(GLIB_LIBS) \
# 	$(LIBXML_LIBS) \
# 	$(GIO_LIBS) \
# 	$(GEE_LIBS) \
# 	$(VALA_LIBS) \
# 	$(NULL)
#
# include_HEADERS = \
# 	$(top_builddir)/gxml/gxml-dom.h \
# 	$(NULL)
#
#
# pkgconfigdir = $(libdir)/pkgconfig
# pkgconfig_DATA = libgxmldom-0.2.pc
#
# gxmlincludedir=$(includedir)/libgxmldom-0.2
# gxmlinclude_HEADERS= gxml-dom.h
#
# # GObject Introspection
#
# if ENABLE_GI_SYSTEM_INSTALL
# girdir = $(INTROSPECTION_GIRDIR)
# typelibsdir = $(INTROSPECTION_TYPELIBDIR)
# else
# girdir = $(datadir)/gir-1.0
# typelibsdir = $(libdir)/girepository-1.0
# endif
#
# # GIR files are generated automatically by Valac so is not necessary to scan source code to generate it
# INTROSPECTION_GIRS =
# INTROSPECTION_GIRS += GXmlDom-0.2.gir
# INTROSPECTION_COMPILER_ARGS = \
#     --includedir=.
#
# GXmlDom-0.2.typelib: $(INTROSPECTION_GIRS)
# 	$(INTROSPECTION_COMPILER) $(INTROSPECTION_COMPILER_ARGS)  $< -o $@
#
# gir_DATA = $(INTROSPECTION_GIRS)
# typelibs_DATA = GXmlDom-0.2.typelib
#
# vapi: gxmldom-0.2.vapi
# vapidir = $(VALA_VAPIDIR)
# vapi_DATA = gxmldom-0.2.vapi
#
# CLEANFILES += $(INTROSPECTION_GIRS) $(typelibs_DATA) gxml-0.2.vapi gxml-dom.h
#
# EXTRA_DIST = \
# 	libgxmldom-0.2.pc \
# 	$(libgxmldom_la_VALASOURCES:.vala=.c) \
# 	$(vapi_DATA) \
# 	$(typelibs_DATA) \
# 	$(INTROSPECTION_GIRS) \
# 	gxml.vala.stamp
#
