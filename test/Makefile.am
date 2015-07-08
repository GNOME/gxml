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
	-I$(top_builddir) \
	-DTEST_DIR=\"$(builddir)\" \
	$(NULL)


noinst_PROGRAMS = $(TEST_PROGS)

TEST_PROGS += gxml_test

sources = \
	tests-config.vala \
	AttrTest.vala \
	CharacterDataTest.vala \
	DocumentTest.vala \
	NodeTest.vala \
	ElementTest.vala \
	GXmlTest.vala \
	NamespaceTest.vala \
	NodeListTest.vala \
	TextTest.vala \
	ValaLibxml2Test.vala \
	EnumerationTest.vala \
	SerializableTest.vala \
	SerializationTest.vala \
	SerializableObjectModelTest.vala \
	SerializableObjectModel-Tw-Test.vala \
	SerializableGeeTreeMapTest.vala \
	SerializableGeeDualKeyMapTest.vala \
	SerializableGeeArrayListTest.vala \
	SerializableGeeHashMapTest.vala \
	SerializableGeeCollectionsTest.vala \
	SerializableGeeCollections-Tw-Test.vala \
	SerializableBasicTypesTest.vala \
	gxml-performance.vala \
	TwElementTest.vala \
	TwDocumentTest.vala \
	TwCDATATest.vala \
	TwCommentTest.vala \
	TwProcessingInstructionTest.vala \
	$(NULL)

gxml_test.vala.stamp: $(sources)
	$(VALAC) $(AM_VALAFLAGS) $^

$(sources:.vala=.c): gxml_test.vala.stamp

gxml_test_SOURCES = $(sources:.vala=.c)

AM_VALAFLAGS = \
	$(top_srcdir)/vapi/config.vapi \
	$(top_srcdir)/vapi/gxml-test.vapi \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_builddir)/gxml \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg posix \
	--pkg gxml-0.6 \
	--pkg libxml-2.0 \
	-C \
	-g \
	-X -DTEST_DIR=$(top_srcdir)/test \
	$(NULL)

if DEBUG
AM_VALAFLAGS+= -D DEBUG
endif

if ENABLE_PERFORMANCE_TESTS
AM_VALAFLAGS += \
  -D ENABLE_PERFORMANCE_TESTS
endif

gxml_test_LDADD = \
	$(AM_LDADD) \
	$(GLIB_LIBS) \
	$(GEE_LIBS) \
	$(GXML_LIBS) \
	$(LIBXML_LIBS) \
	$(GIO_LIBS) \
	../gxml/libgxml-0.6.la
	$(NULL)

gxml_test_LDFLAGS = $(AM_LDFLAGS)



# include_HEADERS = \
# 	$(top_builddir)/gxml/gxml.h \
# 	$(NULL)

#...

BUILT_SOURCES = gxml_test.vala.stamp

CLEANFILES = $(gxml_test_SOURCES:.vala=.c) $(BUILT_SOURCES) gxml_test

# TODO: should we add *.c to this list?, or is there a var of generated .c we can put in CLEANFILES?

DISTCLEANFILES = \
  _serialization_test_*.xml \
  test-large-tw.xml \
  tw-test.xml

EXTRA_DIST += \
	$(sources) \
	test-large.xml \
	test_invalid.xml \
	test_with_ns.xml \
	test_out_path_expected.xml \
	test_out_stream_expected.xml \
	test.xml \
	test-collection.xml \
	$(NULL)

