-include $(top_srcdir)/git.mk
CLEANFILES=

VALADOC_FLAGS = \
	--force \
	--package-name=gxml-$(API_VERSION) \
	--package-version=$(PACKAGE_VERSION) \
	$(top_srcdir)/vapi/libxml-2.0.vapi \
	--pkg glib-2.0 \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--vapidir=$(top_srcdir)/gxml \
	--vapidir=$(top_srcdir)/vapi \
	--wiki=$(top_srcdir)/docs/valadoc/wiki

gxml_wiki_pages = \
	concepts \
	glossary \
	debugging

WIKI_FILES = \
	$(top_srcdir)/docs/valadoc/wiki/*.valadoc

sources= \
	$(top_srcdir)/gxml/*.vala

distclean_dirs=

if ENABLE_DEVHELP_DOCS
gxmldocdir=$(datadir)/devhelp/books/gxml-$(API_VERSION)
gxmldoc_DATA = \
	gxml/gxml-$(API_VERSION)/gxml-$(API_VERSION).devhelp2 \
	gxml/gxml-$(API_VERSION)/*.png \
	gxml/gxml-$(API_VERSION)/*.html \
	gxml/gxml-$(API_VERSION)/*.htm \
	gxml/gxml-$(API_VERSION)/*.css \
	gxml/gxml-$(API_VERSION)/*.js

gxmldocimgdir=$(datadir)/devhelp/books/gxml-$(API_VERSION)/img
gxmldocimg_DATA=\
	gxml/gxml-$(API_VERSION)/img/*

$(gxmldoc_DATA) $(gxmldocimg_DATA): gxml-doc

gxml-doc:
	$(VALADOC) -o gxml --doclet=devhelp $(VALADOC_FLAGS) $(sources)

all: gxml-doc

clean-local: clean-local-gxml-doc
.PHONY: clean-local-gxml-doc
clean-local-gxml-doc:
	-rm -rf gxml

endif

if ENABLE_GTK_DOCS
gxmlgtkdocdir=$(datadir)/gtk-doc/html/gxml
gxmlgtkdoc_DATA= \
	gtk-doc/gxml/*.txt \
	gtk-doc/gxml/html/*.bak \
	gtk-doc/gxml/html/*.types \
	gtk-doc/gxml/html/sgml.stamp

$(gxmlgtkdoc_DATA): gxml-gtk-doc

gxml-gtk-doc:
	$(VALADOC) -o gtk-doc/gxml --doclet=gtkdoc \
	-X $(top_builddir)/gxml/gxml.h \
	$(VALADOC_FLAGS) $(sources)

all: gxml-gtk-doc

clean-local: clean-local-gtk-doc
.PHONY: clean-local-gtk-doc
clean-local-gtk-doc:
	-rm -rf gtk-doc

endif

EXTRA_DIST = \
	$(WIKI_FILES)
