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
	SerializablePropertyBoolTest.vala \
	SerializablePropertyDoubleTest.vala \
	SerializablePropertyFloatTest.vala \
	SerializablePropertyEnumTest.vala \
	SerializablePropertyIntTest.vala \
	SerializablePropertyValueListTest.vala \
	SerializableObjectModelTest.vala \
	SerializableObjectModel-TDocument-Test.vala \
	SerializableGeeTreeMapTest.vala \
	SerializableGeeDualKeyMapTest.vala \
	SerializableGeeArrayListTest.vala \
	SerializableGeeHashMapTest.vala \
	SerializableGeeCollectionsTest.vala \
	SerializableGeeCollections-TDocument-Test.vala \
	SerializableBasicTypesTest.vala \
	gxml-performance.vala \
	TElementTest.vala \
	TDocumentTest.vala \
	TCDATATest.vala \
	TCommentTest.vala \
	TProcessingInstructionTest.vala \
	GDocumentTest.vala \
	GElementTest.vala \
	GAttributeTest.vala \
	HtmlDocumentTest.vala \
	DomGDocumentTest.vala \
	$(NULL)

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

gxml_test_SOURCES = $(sources:.vala=.c)

AM_VALAFLAGS = \
	--vapidir=$(VAPIDIR) \
	$(top_srcdir)/vapi/config.vapi \
	$(top_srcdir)/vapi/gxml-test.vapi \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_builddir)/gxml \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg posix \
	--pkg gxml-0.12 \
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
	../gxml/libgxml-0.12.la
	$(NULL)

gxml_test_LDFLAGS = $(AM_LDFLAGS)



# include_HEADERS = \
# 	$(top_builddir)/gxml/gxml.h \
# 	$(NULL)

#...

CLEANFILES = \
	$(gxml_test_SOURCES:.vala=.c) \
	$(BUILT_SOURCES) \
	gxml_test \
	vala-stamp

# TODO: should we add *.c to this list?, or is there a var of generated .c we can put in CLEANFILES?

DISTCLEANFILES = \
  _serialization_test_*.xml \
  test-large-tw.xml \
  tw-test.xml \
  t-test.xml

EXTRA_DIST += \
	$(sources) \
	test-large.xml \
	test_invalid.xml \
	test_with_ns.xml \
	test_out_path_expected.xml \
	test_out_stream_expected.xml \
	test.xml \
	test-collection.xml \
	index.html \
	t-read-test.xml \
	gdocument-read.xml \
	$(NULL)

