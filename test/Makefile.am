include $(top_srcdir)/gtester.mk

NULL =

### General compilation flags
AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\"

AM_CFLAGS = \
	-Wall \
	-g \
	$(GLIB_CFLAGS) \
	$(GXML_CFLAGS) \
	$(GEE_CFLAGS) \
	$(LIBXML_CFLAGS) \
	-I$(srcdir)/gxml \
	$(NULL)

VALAC=valac

noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS += gxml_test

gxml_test_SOURCES = \
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

gxml_test.vala.stamp: $(gxml_test_SOURCES)

gxml_test_VALAFLAGS = \
	$(AM_VALAFLAGS) \
	$(ERROR_VALAFLAGS) \
	$(top_srcdir)/vapi/config.vapi \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/gxml \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg posix \
	--pkg gxml \
	--pkg libxml-2.0 \
	$(NULL)

gxml_test_LDADD = \
	$(AM_LDADD) \
	$(GLIB_LIBS) \
	$(GXML_LIBS) \
	-L$(top_srcdir)/gxml -lgxml \
	$(NULL)

gxml_test_LDFLAGS = $(AM_LDFLAGS)



# include_HEADERS = \
# 	$(top_builddir)/gxml/gxml.h \
# 	$(NULL)

#...

BUILT_SOURCES = gxml_test.vala.stamp

CLEANFILES =  $(BUILT_SOURCES) gxml_test

EXTRA_DIST += \
	$(NULL)

