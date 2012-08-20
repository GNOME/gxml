include $(top_srcdir)/gtester.mk

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
	--pkg gxml-0.3 \
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
	-L$(top_srcdir)/gxml -lgxml \
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

