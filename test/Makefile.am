include $(top_srcdir)/gtester.mk

NULL =

### General compilation flags
AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\"

AM_CFLAGS = \
	-g \
	$(GLIB_CFLAGS) \
	$(GXML_CFLAGS) \
	$(GEE_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(GIO_CFLAGS) \
	-I$(top_srcdir) \
	-DTEST_DIR=\""$(top_srcdir)/test"\" \
	$(NULL)


noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS += gxml_test

gxml_test_SOURCES = \
	AttrTest.vala \
	CharacterDataTest.vala \
	DocumentTest.vala \
	NodeTest.vala \
	ElementTest.vala \
	GXmlTest.vala \
	NodeListTest.vala \
	TextTest.vala \
	ValaLibxml2Test.vala \
	EnumerationTest.vala \
	SerializableTest.vala \
	SerializationTest.vala \
	SerializableObjectModelTest.vala \
	SerializableGeeTreeMapTest.vala \
	SerializableGeeDualKeyMapTest.vala \
	SerializableGeeArrayListTest.vala \
	SerializableGeeHashMapTest.vala \
	SerializableGeeCollectionsTest.vala \
	SerializableBasicTypesTest.vala \
	$(NULL)

gxml_test.vala.stamp: $(gxml_test_SOURCES)

gxml_test_VALAFLAGS = \
	$(AM_VALAFLAGS) \
	$(ERROR_VALAFLAGS) \
	$(top_srcdir)/vapi/config.vapi \
	$(top_srcdir)/vapi/gxml-test.vapi \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/gxml \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg posix \
	--pkg gxml-0.4 \
	--pkg libxml-2.0 \
	-X -DTEST_DIR=$(top_srcdir)/test \
	$(NULL)

gxml_test_LDADD = \
	$(AM_LDADD) \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(GXML_LIBS) \
	$(LIBXML_LIBS) \
	$(GIO_LIBS) \
	../gxml/libgxml-0.4.la
	$(NULL)

gxml_test_LDFLAGS = $(AM_LDFLAGS)



# include_HEADERS = \
# 	$(top_builddir)/gxml/gxml.h \
# 	$(NULL)

#...

BUILT_SOURCES = gxml_test.vala.stamp

CLEANFILES = $(gxml_test_SOURCES:.vala=.c) $(BUILT_SOURCES) gxml_test

# TODO: should we add *.c to this list?, or is there a var of generated .c we can put in CLEANFILES?

DISTCLEANFILES = _serialization_test_*.xml

EXTRA_DIST += \
	test_out_path_expected.xml \
	test_out_stream_expected.xml \
	test.xml \
	$(NULL)

